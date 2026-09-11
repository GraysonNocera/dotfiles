return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- `gotmpl` is not for a filetype of its own: Hugo layouts stay `html` so
    -- vscode-html-language-server keeps attaching. It is injected into the
    -- `{{ ... }}` regions by after/queries/html/injections.scm.
    ensure_installed = { "go", "gomod", "gosum", "gowork", "gotmpl" },
  },
}
