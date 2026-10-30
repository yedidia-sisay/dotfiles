return {
  "folke/lazydev.nvim",
  ft = "lua", -- only load for Lua files
  opts = {
    library = {
      -- You can add other paths if needed, e.g., plugins with Lua APIs
      { path = "luvit-meta/library", words = { "vim%.uv" } }, -- for vim.uv types
    },
  },
}
