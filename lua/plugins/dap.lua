return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'nvim-neotest/nvim-nio' },
    },
    'mxsdev/nvim-dap-vscode-js',
  },
  keys = {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'Step out' },
    { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle DAP UI' },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    dapui.setup()

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    require('dap-vscode-js').setup({
      debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter',
      adapters = { 'pwa-node', 'pwa-chrome' },
    })

    for _, language in ipairs({ 'typescript', 'typescriptreact' }) do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Jest Tests',
          runtimeExecutable = 'node',
          runtimeArgs = { '${workspaceFolder}/node_modules/.bin/jest', '--runInBand' },
          rootPath = '${workspaceFolder}',
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome (ng serve)',
          url = 'http://localhost:4200',
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end
  end,
}
