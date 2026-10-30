return {
  {
    "github/copilot.vim",
    lazy = true,

    -- Only load when one of these commands is executed
    cmd = { "Copilot", "CopilotSetup", "CopilotAuth" },

    init = function()
      -- When it eventually loads, start disabled until you enable it
      vim.g.copilot_enabled = 0
      -- vim.g.copilot_no_tab_map = true
    end,

    config = function()
      vim.keymap.set("n", "<leader>ce", "<cmd>Copilot enable<cr>",  { desc = "Copilot: Enable" })
      vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<cr>", { desc = "Copilot: Disable" })

      -- Optional convenience: load+enable in one go
      vim.api.nvim_create_user_command("CopilotOn", function()
        vim.cmd("Copilot enable")
      end, {})
    end,
  },
}
