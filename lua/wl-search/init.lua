-- Date:   Sun Oct 20 14:48:49 2024
-- Mail:   lunar_ubuntu@qq.com
-- Author: https://github.com/xiaoqixian

local M = {}

local default_config = {
  enabled = true,
  keep_hl_on_leaving = true
}

function M.setup(opts)
  M.config = vim.tbl_extend("keep", opts or default_config, default_config)
  -- local log = require("wl-search.log").new("wl-search.log")
  M.win_patterns = {}
  M.winlocal_hl_inited = false

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
    M.winlocal_hl_inited = true
  end

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
      if M.config.enabled then
        local win = vim.api.nvim_get_current_win()
        local win_pat = vim.fn.getreg("/")
        M.win_patterns[win] = win_pat

        if M.config.keep_hl_on_leaving then
          if vim.v.hlsearch == 1 then
            switch_hl(true)
          end

          if win_pat then
            if M.winlocal_hl_inited then
              vim.cmd("syn clear WinLocalSearch")
            end
            vim.cmd(("syn match WinLocalSearch /%s/"):format(win_pat))
          end
          -- shadow the global Search highlight
          vim.api.nvim_win_set_option(0, "winhighlight", "Search:WinLocalSearchShadow")
        end
      end
    end
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
      if M.config.enabled then
        local win = vim.api.nvim_get_current_win()
        ---@type string
        local pat = M.win_patterns[win]
        if pat then
          vim.fn.setreg("/", pat)
        end

        if M.config.keep_hl_on_leaving then
          vim.api.nvim_win_set_option(0, "winhighlight", "WinLocalSearch:WinLocalSearchShadow")
        end
      end
    end
  })

  vim.api.nvim_create_user_command(
    "WinLocalSearch",
    function(opts)
      if opts.args[1] == "enable" then
        M.config.enabled = true
      elseif opts.args[1] == "disable" then
        M.config.enabled = false
      end
    end,
    {
      nargs = 1,
      complete = function(_, _, _)
        return { "enable", "disable" }
      end
    }
  )
end

return M
