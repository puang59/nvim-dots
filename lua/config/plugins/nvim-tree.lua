return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        -- Show hidden files (files starting with .)
        filters = {
          dotfiles = false,  -- Show dotfiles like .env, .gitignore, etc.
          git_ignored = false,  -- Show git ignored files
        },
        
        -- Auto-highlight current file
        update_focused_file = {
          enable = true,  -- Enable auto-highlighting
          update_root = false,  -- Don't change root when focusing
        },
        
        -- Other useful settings
        view = {
          width = 30,
          side = "right",
        },
        
        renderer = {
          highlight_git = true,
          highlight_opened_files = "name",  -- Highlight opened files
          indent_markers = {
            enable = true,
          },
        },
        
        actions = {
          open_file = {
            quit_on_open = false,  -- Keep tree open when opening files
          },
        },
      }
    end,
  }
}
