local M = {
  "FabijanZulj/blame.nvim",
}

function M.config()
  local winbar_settings_group = vim.api.nvim_create_augroup("winbar_settings", { clear = true })

  vim.api.nvim_create_autocmd({ "WinEnter", "WinResized" }, {
    group = winbar_settings_group,
    desc = "Hide lualine winbar when blame is open",
    callback = function()
      local win_ids = vim.api.nvim_list_wins()

      for _, win_id in ipairs(win_ids) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        local buf_ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
        if buf_ft == "blame" then
          require("barbecue.ui").toggle(false)
          break -- Exit the loop since a 'blame' filetype was found
        else
          require("barbecue.ui").toggle(true)
        end
      end
    end,
  })
  require("blame").setup {
    date_format = "%d.%m.%Y",
    virtual_style = "right",
    views = {
      window = window_view,
      virtual = virtual_view,
      default = window_view,
    },
    merge_consecutive = false,
    max_summary_width = 30,
    colors = nil,
    commit_detail_view = "vsplit",
    -- format_fn = formats.commit_date_author_fn,
    mappings = {
      commit_info = "i",
      stack_push = "<TAB>",
      stack_pop = "<BS>",
      show_commit = "<CR>",
      close = { "<esc>", "q" },
    },
  }
end

return M
