local M = {}

local TEST_BASE = { it = true, test = true, fit = true, xit = true }
local DESCRIBE_BASE = { describe = true, fdescribe = true, xdescribe = true }

--- @param file string
--- @return boolean whether `file`'s basename matches one of test_glob
function M.is_test_file(file)
  local name = vim.fs.basename(file)
  for _, glob in ipairs(require('jest.config').options.test_glob) do
    local ok, lpeg_pattern = pcall(vim.glob.to_lpeg, glob)
    if ok and lpeg_pattern:match(name) then
      return true
    end
  end
  return false
end

-- JS regex metacharacters that need escaping in literal segments.
local SPECIAL = {}
for c in ('.*+?^${}()|[]\\'):gmatch('.') do
  SPECIAL[c] = true
end

--- Escape a literal string for safe use inside a JS regex.
--- @param str string
--- @return string
local function escape_regex(str)
  local out = {}
  for i = 1, #str do
    local c = str:sub(i, i)
    out[#out + 1] = SPECIAL[c] and ('\\' .. c) or c
  end
  return table.concat(out)
end
M.escape_regex = escape_regex

-- jest's printf-style .each placeholders: %s %d %i %f %j %o %p %# %%
local PRINTF = {}
for _, tok in ipairs({ '%#', '%%', '%s', '%d', '%i', '%f', '%j', '%o', '%p' }) do
  PRINTF[tok] = true
end

--- Convert an `it.each`/`describe.each` title template (containing printf-style
--- placeholders or `$variable` interpolations) into a regex that matches any
--- of its generated, interpolated titles.
--- @param title string
--- @return string
local function each_title_to_pattern(title)
  local i, n, parts = 1, #title, {}
  while i <= n do
    local two = title:sub(i, i + 1)
    if PRINTF[two] then
      parts[#parts + 1] = '.*'
      i = i + 2
    else
      local dollar = title:match('^%$[%w_.]+', i)
      if dollar then
        parts[#parts + 1] = '.*'
        i = i + #dollar
      else
        parts[#parts + 1] = escape_regex(title:sub(i, i))
        i = i + 1
      end
    end
  end
  return table.concat(parts)
end
M.each_title_to_pattern = each_title_to_pattern

--- Resolve the base jest global (it/test/describe/...) and modifier
--- (each/only/skip/concurrent) a call_expression's `function` node refers to.
--- @param fn_node TSNode
--- @param bufnr integer
--- @return string|nil base
--- @return string|nil modifier
local function call_target(fn_node, bufnr)
  local t = fn_node:type()
  if t == 'identifier' then
    return vim.treesitter.get_node_text(fn_node, bufnr), nil
  elseif t == 'member_expression' then
    local object = fn_node:field('object')[1]
    local property = fn_node:field('property')[1]
    if object and property then
      local base = call_target(object, bufnr)
      if base then
        return base, vim.treesitter.get_node_text(property, bufnr)
      end
    end
  elseif t == 'call_expression' then
    -- chained call, e.g. the `it.each(table)` part of `it.each(table)('title', fn)`
    local inner = fn_node:field('function')[1]
    if inner then
      return call_target(inner, bufnr)
    end
  end
  return nil, nil
end

--- @param call_node TSNode call_expression
--- @param bufnr integer
--- @return string|nil the raw (unquoted) text of the first string/template argument
local function first_string_title(call_node, bufnr)
  local args = call_node:field('arguments')[1]
  if not args then
    return nil
  end
  for child in args:iter_children() do
    local t = child:type()
    if t == 'string' or t == 'template_string' then
      local text = vim.treesitter.get_node_text(child, bufnr)
      return text:sub(2, -2)
    end
  end
  return nil
end

--- Find the it/test/describe call enclosing the cursor and build a
--- --testNamePattern regex matching its full (ancestor-qualified) name.
--- @param bufnr integer|nil
--- @return table|nil spec { pattern: string, line: integer }
--- @return string|nil err
function M.nearest(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil, 'no treesitter parser available for this buffer'
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local node = root:named_descendant_for_range(row, col, row, col)
  if not node then
    return nil, 'no node found at cursor'
  end

  local match = nil -- { title, is_each, node }
  local ancestors = {} -- describe titles, outermost first

  local n = node
  while n do
    if n:type() == 'call_expression' then
      local fn = n:field('function')[1]
      if fn then
        local base, modifier = call_target(fn, bufnr)
        if base then
          local title = first_string_title(n, bufnr)
          if title then
            if TEST_BASE[base] and not match then
              match = { title = title, is_each = modifier == 'each', node = n }
            elseif DESCRIBE_BASE[base] then
              table.insert(ancestors, 1, { title = title, is_each = modifier == 'each' })
            end
          end
        end
      end
    end
    n = n:parent()
  end

  if not match then
    return nil, 'no test found under cursor'
  end

  local segments = {}
  for _, a in ipairs(ancestors) do
    table.insert(segments, a.is_each and each_title_to_pattern(a.title) or escape_regex(a.title))
  end
  table.insert(segments, match.is_each and each_title_to_pattern(match.title) or escape_regex(match.title))

  local start_row = select(1, match.node:range())

  return {
    pattern = '^' .. table.concat(segments, ' ') .. '$',
    line = start_row + 1,
  },
    nil
end

local EXT_LANG = {
  js = 'javascript',
  jsx = 'javascriptreact',
  mjs = 'javascript',
  cjs = 'javascript',
  ts = 'typescript',
  tsx = 'tsx',
}

--- @param filepath string
--- @return TSNode|nil root
--- @return string|nil source
local function parse_file(filepath)
  local ext = filepath:match('%.([%w]+)$')
  local lang = ext and EXT_LANG[ext]
  if not lang then
    return nil, nil
  end

  local read_ok, lines = pcall(vim.fn.readfile, filepath)
  if not read_ok then
    return nil, nil
  end
  local source = table.concat(lines, '\n')

  local parse_ok, parser = pcall(vim.treesitter.get_string_parser, source, lang)
  if not parse_ok or not parser then
    return nil, nil
  end
  return parser:parse()[1]:root(), source
end

--- Walk the whole file once, returning every test call site (literal and
--- .each alike). Literal tests get their exact fullName; .each tests get a
--- --testNamePattern-style regex, since their titles are runtime-interpolated
--- and can't be known statically.
--- @param filepath string
--- @return table[] { line, kind = 'literal'|'each', fullName?, pattern? }
function M.file_all_tests(filepath)
  local root, source = parse_file(filepath)
  if not root then
    return {}
  end

  local tests = {}

  local function visit(node, ancestors)
    if node:type() == 'call_expression' then
      local fn = node:field('function')[1]
      if fn then
        local base, modifier = call_target(fn, source)
        if base then
          local title = first_string_title(node, source)
          if title then
            local is_each = modifier == 'each'
            local start_row = select(1, node:range())
            if TEST_BASE[base] then
              if is_each then
                local segments = {}
                for _, a in ipairs(ancestors) do
                  table.insert(segments, a.is_each and each_title_to_pattern(a.title) or escape_regex(a.title))
                end
                table.insert(segments, each_title_to_pattern(title))
                table.insert(tests, {
                  line = start_row + 1,
                  kind = 'each',
                  pattern = '^' .. table.concat(segments, ' ') .. '$',
                })
              else
                local segments = {}
                for _, a in ipairs(ancestors) do
                  table.insert(segments, a.title)
                end
                table.insert(segments, title)
                table.insert(tests, {
                  line = start_row + 1,
                  kind = 'literal',
                  fullName = table.concat(segments, ' '),
                })
              end
              return -- don't descend into a matched test's own body
            elseif DESCRIBE_BASE[base] then
              table.insert(ancestors, { title = title, is_each = is_each })
              for child in node:iter_children() do
                visit(child, ancestors)
              end
              table.remove(ancestors)
              return
            end
          end
        end
      end
    end
    for child in node:iter_children() do
      visit(child, ancestors)
    end
  end

  visit(root, {})
  return tests
end

--- jest's `--testLocationInResults` reports locations against the
--- transformed/compiled source (e.g. under ts-jest), not the original file,
--- so it's unreliable for jump-to-source. Map every test's real source line
--- instead: literal tests get an exact fullName key; .each-generated tests
--- get a --testNamePattern-style regex to match a result row's fullName
--- against, since their titles are runtime-interpolated and can't be known
--- statically.
--- @param filepath string
--- @return table<string, integer> literal fullName -> line
--- @return table[] each { pattern: string, line: integer }
function M.file_locations(filepath)
  local literal, each = {}, {}
  for _, t in ipairs(M.file_all_tests(filepath)) do
    if t.kind == 'literal' then
      literal[t.fullName] = t.line
    else
      table.insert(each, { pattern = t.pattern, line = t.line })
    end
  end
  return literal, each
end

return M
