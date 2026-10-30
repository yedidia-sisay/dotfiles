return {
  dir = "~/code/here_nvim/mdservice",
  ft = { "markdown" },
  config = function()
    require("mdservice").setup()
  end,
}

