-- Date:   Sun Oct 20 15:47:59 2024
-- Mail:   lunar_ubuntu@qq.com
-- Author: https://github.com/xiaoqixian

local M = {}

---create a new logger
---@param filename string
---@return table
function M.new(filename)
  local L = {}
  L.path = vim.fn.stdpath("cache") .. "/" .. filename
  do
    local file = io.open(L.path, "w")
    if file then
      file:close()
    end
  end

  ---@param msg string
  function L.log(msg, ...)
    local file = io.open(L.path, "a")
    if not file then
      error("open " .. L.path .. " failed")
    end

    if select("#", ...) == 0 then
      file:write(msg, "\n")
    else
      file:write(msg:format(...), "\n")
    end
    file:close()
  end

  return L
end

return M
