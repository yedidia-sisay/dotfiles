require("catppuccin").setup({
    color_overrides = {
        latte = {
            base = "#C2BFB0",
            sapphire = "#209fb6",
            -- mantle = "#e6e9f0",
            mantle = "#c2bfb8",
            sky = "#04a5e6",
            maroon = "#e64554",
            -- crust = "#000000",
            crust = "#dce0e8",
            mauve = "#8839f0",
            teal = "#17929a",
            pink = "#ea76cc",
            surface2 = "#acb0bf",
            overlay2 = "#7c7f94",
            flamingo = "#dd7879",
            red = "#d20f3a",
            overlay0 = "#9ca0b1",
            overlay1 = "#8c8fa2",
            yellow = "#df8e1e",
            -- lavender = "#7287fe",
            lavender = "#1287fe",
            -- surface1 = "#bcc0cd",
            surface1 = "#28282f",
            -- subtext0 = "#6c6f86",
            subtext0 = "#e04554",
            green = "#40a02c",
            peach = "#fe640c",
            surface0 = "#ccd0db",
            subtext1 = "#5c5f78",
            rosewater = "#dc8a79",
            blue = "#1e66f6",
            text = "#4c4f6a",
        },
    },

})


vim.cmd.colorscheme("catppuccin")

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "catppuccin-latte",
  callback = function()
    vim.api.nvim_set_hl(0, "IlluminatedWordText",  { bg = "#dfdfef" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead",  { bg = "#dfdfff" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#dfdfff" })
  end,
})


