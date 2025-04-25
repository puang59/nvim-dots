return {
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' }
      },

      appearance = {
        nerd_font_variant = 'mono'
      },

      completion = { documentation = { auto_show = false } },
      fuzzy = { implementation = "prefer_rust" },
      signature = { enabled = true }
    },
    opts_extend = { "sources.default" }
  }
}
