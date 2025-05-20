require("config.lazy")

vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars = { eob = ' ' }

-- Add these lines for global settings
vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', 'gra', vim.lsp.buf.code_action)
vim.keymap.set('n', 'grr', vim.lsp.buf.references)

vim.keymap.set('n', '<space>e', '<cmd>Oil<CR>')
vim.keymap.set('n', '<leader>ot', '<cmd>Floaterminal<cr>')

vim.keymap.set("n", "<C-x>3", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>on", "<cmd>NvimTreeToggle<CR>")

-- Add these lines with your other vim.opt settings
vim.opt.tabstop = 2        -- Number of spaces tabs count for
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.softtabstop = 2    -- Number of spaces that a <Tab> counts for

vim.opt.signcolumn = "yes" -- Show sign column by default
vim.cmd([[
  highlight SignColumn guibg=NONE ctermbg=NONE
]])

if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_opacity = 0.5
  vim.g.neovide_cursor_vfx_particle_density = 7.5
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.5
  vim.g.neovide_cursor_vfx_particle_phase = 0.5
  -- increase font size and line height
  vim.g.neovide_font_size = 14.0
  vim.g.neovide_line_height = 1.5
end

-- barbar.lua
vim.keymap.set('n', '<leader>1', '<Cmd>BufferGoto 1<CR>', { desc = 'Go to buffer 1' })
vim.keymap.set('n', '<leader>2', '<Cmd>BufferGoto 2<CR>', { desc = 'Go to buffer 2' })
vim.keymap.set('n', '<leader>3', '<Cmd>BufferGoto 3<CR>', { desc = 'Go to buffer 3' })
vim.keymap.set('n', '<leader>4', '<Cmd>BufferGoto 4<CR>', { desc = 'Go to buffer 4' })
vim.keymap.set('n', '<leader>5', '<Cmd>BufferGoto 5<CR>', { desc = 'Go to buffer 5' })
vim.keymap.set('n', '<leader>c', '<Cmd>BufferClose<CR>', { desc = 'Close current buffer' })
vim.keymap.set('n', '<leader>C', '<Cmd>BufferCloseAllButCurrent<CR>', { desc = 'Close all buffers except current' })