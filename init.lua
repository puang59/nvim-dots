require("config.lazy")

vim.opt.shiftwidth = 4
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
