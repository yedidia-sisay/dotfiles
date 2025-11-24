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
        window = {
          position = "float",
          width = 50,
          height = 40,
        },
      })

      vim.keymap.set("n", "<leader>;", function()
        vim.cmd("Neotree toggle filesystem float")
      end, { desc = "Toggle Neo-tree (float centered)" })
    end,
  },
}


