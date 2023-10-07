-- https://github.com/prichrd/netrw.nvim
-- It's not because we use netrw that we cannot have nice things! This plugin adds a layer of ✨bling✨ and configuration to your favorite file explorer.
-- tldr 
-- Makes file exporer look nice
require("netrw").setup {
  icons = {
    symlink = " ",
    directory = " ",
    file = " ",
  },
  use_devicons = true,
  mappings = {},
}

