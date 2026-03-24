return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
  },
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = { enabled = true },
    panel = { enabled = false },
    -- copilot_model = "claude-sonnet-4.6",
  },
}
