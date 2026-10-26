-- jdtls needs a per-project workspace dir and OS-specific launcher args, so
-- (unlike the other servers in lsp/*.lua) it's started here via nvim-jdtls
-- rather than through vim.lsp.enable().
local jdtls = require('jdtls')

local mason_path = vim.fn.stdpath('data') .. '/mason/packages'
local jdtls_path = mason_path .. '/jdtls'

-- Java paths are set per machine through environment variables, so nothing
-- machine-specific lives in this repo.
--
-- Installed /usr/lib/jvm/java-<N>-openjdk JDKs, oldest first.
local function system_jdks()
  local jdks = {}
  for _, path in ipairs(vim.fn.glob('/usr/lib/jvm/java-*-openjdk', false, true)) do
    local version = tonumber(path:match('java%-(%d+)%-openjdk$'))
    if version then
      table.insert(jdks, { version = version, path = path })
    end
  end
  table.sort(jdks, function(a, b) return a.version < b.version end)
  return jdks
end

-- JDTLS_JAVA_HOME: JDK used to run jdtls itself. Recent jdtls releases need
--   Java 25 or newer. Defaults to the newest installed JDK, then $JAVA_HOME.
local function default_runner()
  local jdks = system_jdks()
  return jdks[#jdks] and jdks[#jdks].path or vim.env.JAVA_HOME or '/usr/lib/jvm/default'
end
local runner_java_home = vim.env.JDTLS_JAVA_HOME or default_runner()
if vim.fn.executable(runner_java_home .. '/bin/java') == 0 then
  vim.notify('jdtls: no java at ' .. runner_java_home .. '/bin/java (set JDTLS_JAVA_HOME)', vim.log.levels.WARN)
  return
end

-- JDTLS_RUNTIMES: JDKs that projects can build against, as
--   "JavaSE-17=/path/to/jdk17,JavaSE-21=/path/to/jdk21".
--   Defaults to every /usr/lib/jvm/java-<N>-openjdk that is installed.
local function java_runtimes()
  local runtimes = {}
  if vim.env.JDTLS_RUNTIMES and vim.env.JDTLS_RUNTIMES ~= '' then
    for entry in vim.gsplit(vim.env.JDTLS_RUNTIMES, ',', { trimempty = true }) do
      local name, path = entry:match('^%s*(.-)%s*=%s*(.-)%s*$')
      if name and path then
        table.insert(runtimes, { name = name, path = vim.fn.expand(path) })
      end
    end
    return runtimes
  end
  for _, jdk in ipairs(system_jdks()) do
    table.insert(runtimes, { name = 'JavaSE-' .. jdk.version, path = jdk.path })
  end
  return runtimes
end

local root_dir = jdtls.setup.find_root({ 'build.gradle', 'settings.gradle', 'pom.xml', '.git' })
if not root_dir then
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

local bundles = {}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n'))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. '/java-test/extension/server/*.jar'), '\n'))
bundles = vim.tbl_filter(function(p) return p ~= '' end, bundles)

require('jdtls').start_or_attach({
  cmd = {
    runner_java_home .. '/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' .. jdtls_path .. '/lombok.jar',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher_jar,
    '-configuration', jdtls_path .. '/config_linux',
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    java = {
      configuration = {
        runtimes = java_runtimes(),
        updateBuildConfiguration = 'interactive',
      },
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          'org.assertj.core.api.Assertions.*',
          'org.junit.jupiter.api.Assertions.*',
        },
      },
      format = { enabled = true },
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    jdtls.setup_dap({ hotcodereplace = 'auto' })
    require('jdtls.dap').setup_dap_main_class_configs()

    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
    vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
    vim.keymap.set('x', '<leader>cv', function() jdtls.extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
    vim.keymap.set('n', '<leader>cm', jdtls.extract_method, vim.tbl_extend('force', opts, { desc = 'Extract method' }))
    vim.keymap.set('x', '<leader>cm', function() jdtls.extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Extract method' }))
    vim.keymap.set('n', '<leader>tn', jdtls.test_nearest_method, vim.tbl_extend('force', opts, { desc = 'Test nearest method' }))
    vim.keymap.set('n', '<leader>tc', jdtls.test_class, vim.tbl_extend('force', opts, { desc = 'Test class' }))
  end,
})
