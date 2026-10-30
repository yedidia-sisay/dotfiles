
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        opts = {
            log_level = "DEBUG",
        },
        strategies = {
            chat = {
                adapter = "gemini_cli",
            },
        },
    },
    -- Use the 'keys' table for keymaps
    keys = {
        -- Keymap for chat (Normal mode)
        { 
            "<leader>cc", 
            function() 
                require("codecompanion").chat() 
            end, 
            mode = "n",
            desc = "Code Companion: Open Chat" 
        },
        -- Keymap for inline assistant (Visual mode)
        { 
            "<leader>ci", 
            function() 
                require("codecompanion").inline_assistant() 
            end, 
            mode = "v",
            desc = "Code Companion: Inline Assist (Visual)" 
        },
    }
}
