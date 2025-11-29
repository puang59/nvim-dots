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

      -- Diagnostic signs with ASCII icons and transparent background
      local signs = {
        Error = "E!",
        Warn  = "W!",
        Hint  = "H>",
        Info  = "I>"
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        -- ensure sign column background is transparent for these icons
        vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
      end

      -- Colors for diagnostic signs
      vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#ff5f5f", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e5c07b", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#61afef", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#98c379", bg = "NONE" })
      vim.diagnostic.config({
        globals = { 'vim' },
        virtual_text = false, -- Disable inline diagnostic text
        signs = true,         -- Keep the gutter signs to show there's an issue
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          header = "",
          prefix = "",
          max_width = 80,
        },
      })

      -- Function to toggle diagnostic location list
      local function toggle_diagnostic_list()
        local loclist = vim.fn.getloclist(0)
        if #loclist > 0 and vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
          -- Location list is open, close it
          vim.cmd('lclose')
        else
          -- Location list is closed or empty, open it with diagnostics
          vim.diagnostic.setloclist()
        end
      end

      -- Function to copy current line diagnostics to clipboard
      local function copy_diagnostic_to_clipboard()
        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
        if #diagnostics == 0 then
          print("No diagnostics on current line")
          return
        end
        local messages = {}
        for _, diagnostic in ipairs(diagnostics) do
          local source = diagnostic.source or "LSP"
          local message = string.format("[%s] %s", source, diagnostic.message)
          table.insert(messages, message)
        end
        local clipboard_text = table.concat(messages, "\n")
        vim.fn.setreg("+", clipboard_text)
        print("Copied diagnostic to clipboard: " .. clipboard_text:sub(1, 50) .. "...")
      end

      -- Keymap to show diagnostics for current line
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
      vim.keymap.set('n', '<leader>D', toggle_diagnostic_list, { desc = 'Toggle all diagnostics list' })
      vim.keymap.set('n', '<leader>cy', copy_diagnostic_to_clipboard, { desc = 'Copy diagnostic to clipboard' })
      -- LSP navigation keymaps
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })

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
            gofumpt = true,
            codelenses = {
              generate = true,
              gc_details = true,
              test = true,
              tidy = true,
            },
            -- format and organize imports via gopls
            semanticTokens = true,
          },
        },
      }

      -- Organize imports on save for Go files (works with existing format-on-save)
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.go',
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { 'source.organizeImports' } }
          local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
          if not result then return end
          for _, res in pairs(result) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, 'utf-16')
              elseif r.command then
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
        end,
      })

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

      -- C/C++ LSP configuration with clangd
      require("lspconfig").clangd.setup {
        capabilities = capabilities,
        on_attach = custom_on_attach,
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        init_options = {
          fallbackFlags = { "-std=c++17" },
        },
        settings = {
          clangd = {
            diagnostics = {
              unusedMacros = true,
              unusedIncludes = true,
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
