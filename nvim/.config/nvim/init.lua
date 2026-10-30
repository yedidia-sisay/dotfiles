
vim.opt.termguicolors = true



require("config.lazy")
require("config.configs")
require("config.theme")
require("config.markdown")




-- the cherry expirement
local cherry = require("cherry")
cherry.setup({
    target_file = "~/code/journal/todo.md"
})


vim.env.NVIM_LOG_LEVEL = nil          -- unset if somehow set
vim.lsp.log.set_level(vim.log.levels.ERROR)  -- 4 (very quiet)
