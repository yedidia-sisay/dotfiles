return {
  -- LSP configs
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "kotlin_lsp",
          "clangd",
          "tinymist", -- 1. Added Tinymist to auto-installer
        },
        automatic_installation = true,
      })

      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "<leader>id", vim.lsp.buf.definition, "Go to definition")
        map("n", "<leader>ir", vim.lsp.buf.references, "References")
        map("n", "<leader>ii", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>ie", vim.diagnostic.open_float, "Diagnostics") -- Fixed desc
        map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format buffer")
      end

      -- Existing Server Configs...
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { python = { analysis = { typeCheckingMode = "basic" } } },
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = { vim.env.VIMRUNTIME, vim.fn.stdpath("data") .. "/lazy" },
              checkThirdParty = false,
            },
          },
        },
      })

      -- 2. Added Tinymist Configuration
      vim.lsp.config("tinymist", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          exportPdf = "disable", -- Auto-exports PDF whenever you save
          preview = "disable",
        },
      })

      vim.lsp.config("kotlin_lsp", { capabilities = capabilities, on_attach = on_attach })

      -- Better clangd configuration for C/C++
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          fallbackFlags = { "-std=c++20" },   -- Change to c++17 or c++23 if you prefer
          usePlaceholders = true,
          completeUnimported = true,
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
      })


      vim.diagnostic.config({
        virtual_text = false,
        float = { border = "rounded", source = "if_many" },
      })
    end,
  },

  -- Completion config
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },
}
