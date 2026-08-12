local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local function entry_maker(script)
  return {
    value = script,
    display = string.format('%-20s %s', script.name, script.command),
    ordinal = script.name,
  }
end

--- Pick an npm-scripts entry to run, from the project root containing the
--- current buffer (or cwd).
function M.pick()
  local file = vim.api.nvim_buf_get_name(0)
  local root = require('npm.root').find_root(file ~= '' and file or nil)

  local list, err = require('npm.scripts').list(root)
  if err then
    vim.notify(err, vim.log.levels.WARN, { title = 'Npm' })
    return
  end

  pickers
    .new({}, {
      prompt_title = 'Npm: run script (' .. root .. ')',
      finder = finders.new_table({ results = list, entry_maker = entry_maker }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            require('npm').run_in(root, entry.value.name)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
