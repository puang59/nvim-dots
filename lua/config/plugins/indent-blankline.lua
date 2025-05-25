return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      -- Function to set highlights with a lighter color
      local function set_indent_highlights()
        vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#1a1a1a" })
        vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#2a2a2a" })
      end
      
      -- Set highlights initially
      set_indent_highlights()
      
      -- Re-apply highlights after colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_indent_highlights,
      })
      
      require("indent_blankline").setup {
        char = "▏",
        show_trailing_blankline_indent = false,
        show_first_indent_level = false,
        filetype_exclude = {
          "help",
          "packer",
          "lspinfo",
          "TelescopePrompt",
          "TelescopeResults",
          "alpha",
          "neo-tree",
          "Trouble",
          "lazy",
          "",
        },
        buftype_exclude = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      }
    end
  }
}
