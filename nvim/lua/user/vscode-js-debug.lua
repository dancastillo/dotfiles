local M = {
  "microsoft/vscode-js-debug",
  opt = true,
  build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
}

function M.config() end

return M
