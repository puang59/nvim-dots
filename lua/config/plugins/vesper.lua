return {
  {
    'datsfilipe/vesper.nvim',
    config = function()
      require('vesper').setup({
        transparent = false,
        italics = {
          comments = true,
          keywords = true,
          functions = true,
          strings = true,
          variables = true,
        },
        overrides = {},
        palette_overrides = {
          white = "#a0a0a0",
        }
      })
      vim.cmd("colorscheme vesper")
    end
  },
}
