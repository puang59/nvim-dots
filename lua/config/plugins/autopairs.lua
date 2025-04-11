return {
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true, -- enable treesitter
        ts_config = {
          lua = {'string'},-- don't add pairs in lua string treesitter nodes
          javascript = {'template_string'},
          java = false,-- don't check treesitter on java
        }
      })
    end
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup()
    end
  }
} 