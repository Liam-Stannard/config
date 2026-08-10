-- jdtls needs a per-project workspace dir and OS-specific launcher args, so
-- (unlike the other servers in lsp/*.lua) it's started here via nvim-jdtls
-- rather than through vim.lsp.enable().
local jdtls = require('jdtls')

local mason_path = vim.fn.stdpath('data') .. '/mason/packages'
local jdtls_path = mason_path .. '/jdtls'

-- No JDK is on $PATH. jdtls itself requires a JavaSE-21 runtime to launch
-- (bundled Eclipse plugins won't resolve on anything older) — reuse the JBR
-- that ships with the local IntelliJ install rather than provisioning a
-- separate JDK just to boot the server.
local runner_java_home = '/snap/intellij-idea-community/current/jbr'

-- JDK used to compile/run this project (sourceCompatibility 17), registered
-- below as the JavaSE-17 execution environment.
local project_java_home = vim.fn.expand('~/.jdks/corretto-19.0.2')

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
        runtimes = {
          { name = 'JavaSE-17', path = project_java_home },
        },
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
