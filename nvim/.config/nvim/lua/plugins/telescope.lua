return {
  'nvim-telescope/telescope.nvim',
  tag = 'v0.1.9',
  dependencies = { 'nvim-lua/plenary.nvim' },

  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = {},
      },
      pickers = {
        find_files = {
          hidden = true,     -- <-- show hidden files
          no_ignore = true,  -- <-- show files even if .gitignored
        },
      },
    })

    local builtin = require('telescope.builtin')

    vim.keymap.set('n', '<leader>o', function()
      builtin.find_files({ hidden = true, no_ignore = true })
    end)

    vim.keymap.set('n', '<leader>pf', builtin.git_files, {})
    vim.keymap.set('n', '<leader>ps', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    
    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
  end,
}
