return {
    {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    priority = 1000,

    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,        -- show hidden files
            hide_dotfiles = false, -- do NOT hide dotfiles
            hide_gitignored = false,
          },
        },
        follow_current_file = {
          enabled = true,          -- this makes it open the current file's dir
          leave_dirs_open = true,  -- keeps parent dirs expanded
        },
        hijack_netrw_behavior = "open_current",
        window = {
          position = "float",
          width = 50,
          height = 40,
        },
      })

      -- REPLACE your old keymap with this one (only change)
      vim.keymap.set("n", "<leader>;", function()
        require("neo-tree.command").execute({
          source = "filesystem",
          position = "float",
          toggle = true,
          reveal = true,        -- this is the key line
        })
      end, { desc = "Toggle Neo-tree (float) → reveal current file" })

    end,
  },
}


