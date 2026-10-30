return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon.setup()

    -- Add file
    vim.keymap.set("n", "<leader>m", function()
      harpoon.mark.add_file()
    end, { desc = "Harpoon add file" })

    -- Toggle quick menu
    vim.keymap.set("n", "<leader>u", function()
      harpoon.ui.toggle_quick_menu()
    end, { desc = "Harpoon menu" })

    -- Jump to files
    vim.keymap.set("n", "<C-h>", function() harpoon.ui.nav_file(1) end)
    vim.keymap.set("n", "<C-t>", function() harpoon.ui.nav_file(2) end)
    vim.keymap.set("n", "<C-n>", function() harpoon.ui.nav_file(3) end)
    vim.keymap.set("n", "<C-s>", function() harpoon.ui.nav_file(4) end)
  end,
}
