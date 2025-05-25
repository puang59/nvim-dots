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

      -- Diagnostic signs and virtual text with eye-catching indicators
      local signs = { 
        Error = "🔴", 
        Warn = "⚠️", 
        Hint = "💡", 
        Info = "ℹ️" 
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      vim.diagnostic.config({
        virtual_text = false,  -- Disable inline diagnostic text
        signs = true,  -- Keep the gutter signs to show there's an issue
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          max_width = 80,
        },
      })

      -- Function to toggle diagnostic location list
      local function toggle_diagnostic_list()
        local loclist = vim.fn.getloclist(0)
        if #loclist > 0 and vim.fn.getloclist(0, {winid = 0}).winid ~= 0 then
          -- Location list is open, close it
          vim.cmd('lclose')
        else
          -- Location list is closed or empty, open it with diagnostics
          vim.diagnostic.setloclist()
        end
      end

      -- Keymap to show diagnostics for current line
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
      vim.keymap.set('n', '<leader>D', toggle_diagnostic_list, { desc = 'Toggle all diagnostics list' })

      local function custom_on_attach(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      -- Python LSP configuration with pyright
      require("lspconfig").pyright.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true
            }
          }
        }
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
