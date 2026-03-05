return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      options = {
        "-lualatex",
        "-interaction=nonstopmode",
        "-synctex=1",
        "-shell-escape",
      },
    }
    vim.g.vimtex_view_method = "zathura"
    vim.g.tex_conceal = "abdmg"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_conceal_disable = 0
    vim.g.vimtex_fold_enabled = 1
    vim.keymap.set("n", "<leader>lw", ":VimtexCountWords<CR>")
    vim.keymap.set("n", "<leader>lc", ":VimtexCompile<CR>")
    vim.keymap.set("n", "<leader>lv", ":VimtexView<CR>")
    vim.keymap.set("n", "<leader>le", ":VimtexErrors<CR>")
    vim.keymap.set("n", "<leader>lk", ":VimtexStop<CR>")
    vim.keymap.set("n", "<leader>lt", ":VimtexTocToggle<CR>")
  end,
}
