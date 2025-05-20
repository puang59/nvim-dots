return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      'saghen/blink.cmp',
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      { "SmiteshP/nvim-navic" },
      { "nvimdev/lspsaga.nvim" },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local navic = require("nvim-navic")
      -- Use new API for disabling code action lightbulb
      require('lspsaga').setup({
        lightbulb = {
          enable = false,
        },
      })

      -- Diagnostic signs and virtual text
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          spacing = 2,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      local function custom_on_attach(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      -- Python LSP configuration
      require("lspconfig").pylsp.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                enabled = true,
                maxLineLength = 88,
              },
              pyflakes = {
                enabled = true,
              },
              black = {
                enabled = true,
              },
            },
          },
        },
      }

      require("lspconfig").gopls.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      }

      require("lspconfig").lua_ls.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        settings = {
          Lua = {
            format = {
              indent_size = 2,
            },
          },
        },
      }
      require("lspconfig").ts_ls.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        settings = {
          typescript = {
            format = {
              indentSize = 2,
            },
          },
          javascript = {
            format = {
              indentSize = 2,
            },
          },
        },
      }
      -- Add other language servers here if needed

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          -- Format on save for all LSP-attached buffers
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
            end,
          })
        end,
      })
    end,
  }
}
