local M = {
  "eandrju/cellular-automaton.nvim",
}

function M.config()
  local wk = require "which-key"
  wk.register {
    ["<leader>yr"] = { "<cmd>CellularAutomaton<CR>", "CellularAutomaton make_it_rain" },
    ["<leader>ys"] = { "<cmd>CellularAutomaton<CR>", "CellularAutomaton scramble" },
    ["<leader>yg"] = { "<cmd>CellularAutomaton<CR>", "CellularAutomaton game_of_life" },
  }
end

return M
