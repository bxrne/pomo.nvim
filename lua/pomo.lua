-- main module file
local timer = require("pomo.timer")

---@class Config
---@field opt string Your config option
local config = {
  session_minutes = 25, -- 25 minute sessions
  break_minutes = 5, -- 5 minute break every session
}

---@class MyModule
local M = {}

---@type Config
M.config = config
M.timer = timer

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.start = function()
  return timer.start(M.timer, M.config.session_minutes, M.config.break_minutes)
end

M.stop = function()
  return timer.stop(M.timer)
end

M.reset = function()
  return timer.reset(M.timer)
end

M.status = function()
  return timer.status(M.timer)
end

return M
