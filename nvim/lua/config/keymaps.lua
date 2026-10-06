-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Option+Backspace deletes the previous word in insert and command-line mode
vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Delete previous word" })
