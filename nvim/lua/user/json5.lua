local M = {
  "Joakker/lua-json5",
  build = "./install.sh",
}

function M.config()
  -- https://github.com/neovim/neovim/issues/21749#issuecomment-1378720864
  -- Fix loading of json5
  table.insert(vim._so_trails, "/?.dylib")
end

return M
