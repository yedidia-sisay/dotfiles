



-------------------------------
-- Beta's
--




-------------------------------
-- tab expand rules
--
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")



-------------------------------
-- clipboard rules
vim.opt.clipboard = "unnamedplus" -- copy/paste to the clipboard


-------------------------------
-- number line rules
vim.opt.number = true        -- absolute line numbers
vim.opt.relativenumber = true -- relative line numbers

-- number line for markdown 
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})





-- Toggle cmdheight 0 ↔ 1
vim.o.cmdheight = 0
vim.keymap.set("n", "<leader>ch", function()
  if vim.o.cmdheight == 0 then
    vim.o.cmdheight = 1
  else
    vim.o.cmdheight = 0
  end
end, { desc = "Toggle command bar" })
