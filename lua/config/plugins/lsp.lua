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
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require("lspconfig").lua_ls.setup { 
        capabilities = capabilities,
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
