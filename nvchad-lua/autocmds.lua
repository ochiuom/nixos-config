require "nvchad.autocmds"
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 0
    vim.opt_local.conceallevel = 2  -- enables vimtex math conceal
    vim.opt_local.concealcursor = "nc" -- conceal in normal and command mode
    vim.keymap.set("n", "<leader>s", "z=", { buffer = true })
    vim.keymap.set("n", "<leader>lz", ":ZenMode<CR>", { buffer = true })
  end,
})
