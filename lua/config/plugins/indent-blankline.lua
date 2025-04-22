return {
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      vim.cmd [[highlight IndentBlanklineChar guifg=#0f0f0f]]
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
