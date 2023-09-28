-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = true


-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.filters.custom = {}
lvim.builtin.nvimtree.setup.change_dir = false
lvim.builtin.nvimtree.setup.update_cwd = false
lvim.builtin.nvimtree.setup.update_root = false
lvim.builtin.nvimtree.setup.view.width = 45
lvim.builtin.project.patterns = { ">Projects", "package-lock.json" }
lvim.builtin.dap.active = true

vim.opt.relativenumber = true


lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

-- Color scheme
lvim.colorscheme = "gruvbox-baby"

-- Dont change directory
lvim.builtin.nvimtree.setup.change_dir = false
