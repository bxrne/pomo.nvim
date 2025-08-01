---@class Timer
local Timer = {}

-- Internal state
Timer.state = {
  running = false,
  start_time = nil,
  elapsed_time = 0,
  duration = 0,
}

-- Start the timer
---@param duration number The total duration of the timer in seconds.
function Timer:start(duration)
  if self.state.running then
    print("Timer is already running")
    return
  end
  self.state.running = true
  self.state.start_time = os.time()
  self.state.duration = duration
  print("Timer started for " .. duration .. " seconds")
end

-- Stop the timer
function Timer:stop()
  if not self.state.running then
    print("Timer is not running")
    return
  end
  self.state.elapsed_time = os.time() - self.state.start_time
  self.state.running = false
  print("Timer stopped after " .. self.state.elapsed_time .. " seconds")
end

-- Reset the timer
function Timer:reset()
  self.state.running = false
  self.state.start_time = nil
  self.state.elapsed_time = 0
  self.state.duration = 0
  print("Timer has been reset")
end

return Timer
