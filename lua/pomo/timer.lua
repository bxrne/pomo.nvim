---@class Timer
local Timer = {}
local popup = require("pomo.popup")

-- Internal state
Timer.state = {
  running = false,
  start_time = nil,
  elapsed_time = 0,
  duration = 0,
  break_duration = 0,
  session_timer_id = nil,
  break_timer_id = nil,
  in_break = false,
  cycle_count = 0,
  break_popup_win = nil,
}

-- Start the timer
---@param duration number The total duration of the timer in minutes.
---@param break_duration number The duration of the break in minutes.
function Timer:start(duration, break_duration)
  if self.state.running or self.state.in_break then
    popup.show("Timer is already running!", "Pomodoro Timer", "warn")
    return
  end

  self.state.running = true
  self.state.start_time = vim.fn.localtime()
  self.state.duration = duration
  self.state.break_duration = break_duration
  self.state.in_break = false
  self.state.cycle_count = 0

  popup.show("Timer started for " .. duration .. " minutes", "Pomodoro Timer", "info")

  self:_start_session()
end

-- Internal function to start a work session
function Timer:_start_session()
  if not self.state.running then
    return
  end

  self.state.in_break = false
  self.state.start_time = vim.fn.localtime()

  -- Start session timer
  self.state.session_timer_id = vim.defer_fn(function()
    if self.state.running and not self.state.in_break then
      self:_start_break()
    end
  end, self.state.duration * 60 * 1000)
end

-- Internal function to start a break
function Timer:_start_break()
  if not self.state.running then
    return
  end

  self.state.in_break = true
  self.state.cycle_count = self.state.cycle_count + 1
  self.state.elapsed_time = vim.fn.localtime() - self.state.start_time

  -- Show persistent break popup with escape-to-stop option
  self.state.break_popup_win = popup.show(
    "🍅 Session " .. self.state.cycle_count .. " complete!\nTake a " .. self.state.break_duration .. " minute break",
    "Pomodoro Timer",
    "info",
    true, -- persistent
    function() -- on_dismiss callback
      self:stop()
    end
  )

  -- Start break timer
  self.state.break_timer_id = vim.defer_fn(function()
    if self.state.in_break and self.state.running then
      -- Close break popup if still open
      if self.state.break_popup_win and vim.api.nvim_win_is_valid(self.state.break_popup_win) then
        vim.api.nvim_win_close(self.state.break_popup_win, true)
        self.state.break_popup_win = nil
      end

      popup.show("✨ Break over! Starting session " .. (self.state.cycle_count + 1), "Pomodoro Timer", "info")
      self:_start_session()
    end
  end, self.state.break_duration * 60 * 1000)
end

-- Stop the timer
function Timer:stop()
  if not self.state.running and not self.state.in_break then
    popup.show("No active timer to stop", "Pomodoro Timer", "warn")
    return
  end

  -- Cancel any pending timers (handle test environment)
  if self.state.session_timer_id then
    pcall(vim.fn.timer_stop, self.state.session_timer_id)
    self.state.session_timer_id = nil
  end
  if self.state.break_timer_id then
    pcall(vim.fn.timer_stop, self.state.break_timer_id)
    self.state.break_timer_id = nil
  end

  -- Close break popup if open
  if self.state.break_popup_win and vim.api.nvim_win_is_valid(self.state.break_popup_win) then
    vim.api.nvim_win_close(self.state.break_popup_win, true)
    self.state.break_popup_win = nil
  end

  if self.state.running then
    self.state.elapsed_time = vim.fn.localtime() - self.state.start_time
  end

  local sessions_completed = self.state.cycle_count
  self.state.running = false
  self.state.in_break = false

  if sessions_completed > 0 then
    popup.show("Timer stopped after " .. sessions_completed .. " session(s)", "Pomodoro Timer", "info")
  else
    popup.show("Timer stopped", "Pomodoro Timer", "info")
  end
end

-- Reset the timer
function Timer:reset()
  -- Cancel any pending timers (handle test environment)
  if self.state.session_timer_id then
    pcall(vim.fn.timer_stop, self.state.session_timer_id)
    self.state.session_timer_id = nil
  end
  if self.state.break_timer_id then
    pcall(vim.fn.timer_stop, self.state.break_timer_id)
    self.state.break_timer_id = nil
  end

  -- Close break popup if open
  if self.state.break_popup_win and vim.api.nvim_win_is_valid(self.state.break_popup_win) then
    vim.api.nvim_win_close(self.state.break_popup_win, true)
    self.state.break_popup_win = nil
  end

  self.state.running = false
  self.state.start_time = nil
  self.state.elapsed_time = 0
  self.state.duration = 0
  self.state.break_duration = 0
  self.state.in_break = false
  self.state.cycle_count = 0

  popup.show("Timer reset", "Pomodoro Timer", "info")
end

-- Get current status
function Timer:status()
  if self.state.in_break then
    return "break", self.state.cycle_count
  elseif self.state.running then
    local elapsed = vim.fn.localtime() - self.state.start_time
    local remaining = (self.state.duration * 60) - elapsed
    return "running", remaining, self.state.cycle_count
  else
    return "stopped", self.state.cycle_count
  end
end

return Timer
