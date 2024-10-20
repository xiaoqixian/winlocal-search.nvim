-- Date:   Sun Oct 20 14:48:49 2024
-- Mail:   lunar_ubuntu@qq.com
-- Author: https://github.com/xiaoqixian

local M = {}

---@param on boolean
local function switch_hl(on)
  local hl = nil
  if on then
    hl = vim.api.nvim_get_hl(0, { name = "Search" })
  else
    hl = {
      fg = "none",
      bg = "none"
    }
  end
  vim.api.nvim_set_hl(0, "WinLocalSearch", hl)
end

function M.setup()
  -- local log = require("wl-search.log").new("wl-search.log")
  M.win_patterns = {}

  vim.api.nvim_set_hl(0, "WinLocalSearchShadow", {
    fg = "none",
    bg = "none"
  })

  vim.api.nvim_create_autocmd("CmdLineLeave", {
    pattern = "/",
    callback = function()
      local win = vim.api.nvim_get_current_win()
      assert(win, "get win failed")
      M.win_patterns[win] = vim.fn.getreg("/")
    end
  })

  vim.api.nvim_create_autocmd("CmdLineLeave", {
    pattern = ":",
    callback = function()
      local cmd = vim.fn.getcmdline()
      if cmd == "nohl" or cmd == "nohlsearch" then
        switch_hl(false)
      end
    end
  })

  vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
      local win = vim.api.nvim_get_current_win()
      local win_pat = vim.fn.getreg("/")
      M.win_patterns[win] = win_pat

      if vim.v.hlsearch == 1 then
        switch_hl(true)
      end

      if win_pat then
        vim.cmd(("syn match WinLocalSearch /%s/"):format(win_pat))
      end
      -- shadow the global Search highlight
      vim.api.nvim_win_set_option(0, "winhighlight", "Search:WinLocalSearchShadow")
    end
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
      local win = vim.api.nvim_get_current_win()
      ---@type string
      local pat = M.win_patterns[win]
      if pat then
        vim.fn.setreg("/", pat)
      end
      vim.api.nvim_win_set_option(0, "winhighlight", "WinLocalSearch:WinLocalSearchShadow")
    end
  })
end

return M
