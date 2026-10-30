return {
  dir = "/home/geracha/code/scherry_nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  opts = {
    api_base = "http://localhost:8000/api/v1",
  },

  keys = {
    { "<leader>yl", "<cmd>ScherryList<CR>", desc = "Scherry: Yank Summary of current buffer" },
  },
}
