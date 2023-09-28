lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- greatest remap ever
-- xnoremap("<leader>p", "\"_dp")
lvim.builtin.which_key.mappings["p"] = {
  "\"_dp"
}
-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
}

lvim.builtin.which_key.mappings["a"] = {
  name = "A.I.",
  c = { "<cmd>ChatGPT<cr>", "ChatGPT" },
  a = { "<cmd>ChatGPTActAs<cr>", "Act As GPT" },
  e = { "<cmd>ChatGPTEditWithInstructions<cr>", "Edit GPT" },
  r = { "<cmd>ChatRunCustomCodeAction<cr>", "Code Action GPT" },
  s = { "<cmd>Copilot suggestion<cr>", "Toggle Copilot Suggestion" },
  p = { "<cmd>Copilot panel<cr>", "Toggle Copilot Panel" },
  t = { "<cmd>Copilot toggle<cr>", "Toggle Copilot" },
}
lvim.builtin.which_key.mappings["d"] = {
  name = "Debug",
  b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
  B = { "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", "Breakpoint" },
  c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
  t = { "<cmd>lua require'dap'.terminate()<cr>", "Terminate" },
  -- i = { "<cmd>lua require'dap'.step_into()<cr>", "Into" },
  o = { "<cmd>lua require'dap'.step_over()<cr>", "Over" },
  O = { "<cmd>lua require'dap'.step_out()<cr>", "Out" },
  r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Repl" },
  l = { "<cmd>lua require'dap'.run_last()<cr>", "Last" },
  u = { "<cmd>lua require'dapui'.toggle({ reset = true })<cr>", "UI" },
  e = { "<cmd>lua require'dapui'.eval()<cr>", "Evaluate" },
  f = { "<cmd>lua require'dapui'.float_element()<cr>", "Float Element" },
  x = { "<cmd>lua require'dap'.terminate()<cr>", "Exit" },
  -- t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
}

lvim.builtin.which_key.mappings["n"] = {
  name = "Debug",
  r = { "<cmd>lua require'neotest'.run.run()<cr>", "Run near test" },
  w = { "<cmd>lua require'neotest'.watch.watch()<cr>", "Watch near test" },
  c = { "<cmd>lua require'neotest'.watch.watch({ strategy='dap' })<cr>", "Watch near test" },
  f = { "<cmd>lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", "Run file test" },
  F = { "<cmd>lua require'neotest'.watch.watch(vim.fn.expand('%'))<cr>", "Watch file test" },
  d = { "<cmd>lua require'neotest'.run.run({ strategy='dap' })<cr>", "Debug" },
  s = { "<cmd>lua require'neotest'.run.stop()<cr>", "Stop" },
  a = { "<cmd>lua require'neotest'.run.attach()<cr>", "Attach" },
  l = { "<cmd>lua require'neotest'.run.run_last()<cr>", "Run last test" },
  y = { "<cmd>lua require'neotest'.summary.toggle()<cr>", "Summary toggle" },
}
-- place this in one of your configuration file(s)
local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { remap = true })
vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, { remap = true })
vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, { remap = true })
vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, { remap = true })
