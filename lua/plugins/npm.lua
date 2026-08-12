return {
  -- local-only module (lua/npm/), not an installable plugin; `dir` just
  -- gives lazy.nvim a source so it can lazy-load on these keys.
  'npm.nvim',
  dir = vim.fn.stdpath('config'),
  name = 'npm.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  -- keymaps are user-configurable (npm.config.options.keymaps), so they
  -- can't be declared statically here for lazy.nvim's `keys` trigger; load
  -- eagerly-ish instead, same as jest.lua.
  event = 'VeryLazy',
  config = function()
    require('npm').setup({})
    local npm = require('npm')
    local km = require('npm.config').options.keymaps

    local function map(lhs, fn, desc)
      if lhs then
        vim.keymap.set('n', lhs, fn, { desc = desc })
      end
    end

    map(km.pick, npm.pick, 'Npm: pick script')
    map(km.last, npm.run_last, 'Npm: rerun last script')
    map(km.stop, function() npm.stop() end, 'Npm: stop last script')
    map(km.toggle_output, npm.toggle_output, 'Npm: toggle output window')

    for script, lhs in pairs(km.scripts or {}) do
      map(lhs, function() npm.run(script) end, 'Npm: run ' .. script)
    end

    local function complete_scripts()
      local file = vim.api.nvim_buf_get_name(0)
      local root = require('npm.root').find_root(file ~= '' and file or nil)
      local list = require('npm.scripts').list(root)
      local names = {}
      for _, s in ipairs(list) do
        table.insert(names, s.name)
      end
      return names
    end

    vim.api.nvim_create_user_command('NpmRun', function(cmd_opts)
      if cmd_opts.args ~= '' then
        npm.run(cmd_opts.args)
      else
        npm.pick()
      end
    end, { nargs = '?', complete = complete_scripts })
    vim.api.nvim_create_user_command('NpmPick', npm.pick, {})
    vim.api.nvim_create_user_command('NpmLast', npm.run_last, {})
    vim.api.nvim_create_user_command('NpmStop', function(cmd_opts)
      npm.stop(cmd_opts.args ~= '' and cmd_opts.args or nil)
    end, { nargs = '?' })
    vim.api.nvim_create_user_command('NpmToggle', npm.toggle_output, {})
  end,
}
