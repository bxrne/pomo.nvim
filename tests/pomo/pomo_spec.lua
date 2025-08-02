local plugin = require("pomo")

describe("Pomodoro Plugin", function()
  before_each(function()
    plugin.reset()
  end)

  it("should setup with default config", function()
    plugin.setup()
    assert(plugin.config ~= nil, "Config should be initialized")
    assert(plugin.config.session_minutes == 25, "Default session should be 25 minutes")
    assert(plugin.config.break_minutes == 5, "Default break should be 5 minutes")
  end)

  it("should setup with custom config", function()
    plugin.setup({ session_minutes = 10, break_minutes = 3 })
    assert(plugin.config.session_minutes == 10, "Session length should be set to custom value")
    assert(plugin.config.break_minutes == 3, "Break length should be set to custom value")
  end)

  it("should start the timer", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    assert(plugin.timer.state.running == true, "Timer should be running after start")
    assert(plugin.timer.state.duration == 2, "Timer duration should be set correctly")
    assert(plugin.timer.state.break_duration == 1, "Break duration should be set correctly")
  end)

  it("should not start timer if already running", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    local first_start_time = plugin.timer.state.start_time
    
    -- Try to start again
    plugin.start()
    assert(plugin.timer.state.start_time == first_start_time, "Start time should not change")
  end)

  it("should stop the timer", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    plugin.stop()
    assert(plugin.timer.state.running == false, "Timer should not be running after stop")
    assert(plugin.timer.state.in_break == false, "Should not be in break after stop")
  end)

  it("should reset the timer", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    plugin.reset()
    assert(plugin.timer.state.running == false, "Timer should not be running after reset")
    assert(plugin.timer.state.elapsed_time == 0, "Elapsed time should be reset to 0")
    assert(plugin.timer.state.duration == 0, "Duration should be reset to 0")
    assert(plugin.timer.state.cycle_count == 0, "Cycle count should be reset to 0")
  end)

  it("should return correct status when stopped", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    local status, cycles = plugin.status()
    assert(status == "stopped", "Should return stopped status when timer is not running")
    assert(cycles == 0, "Should return 0 cycles when stopped")
  end)

  it("should return correct status when running", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    local status, remaining, cycles = plugin.status()
    assert(status == "running", "Should return running status when timer is active")
    assert(remaining ~= nil, "Should return remaining time when running")
    assert(remaining > 0, "Remaining time should be positive")
    assert(cycles == 0, "Should return 0 cycles when just started")
  end)

  it("should handle timer cleanup properly", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    assert(plugin.timer.state.session_timer_id ~= nil, "Session timer ID should be set")
    
    plugin.stop()
    assert(plugin.timer.state.session_timer_id == nil, "Session timer ID should be cleared")
  end)

  it("should transition to break state correctly", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    
    -- Simulate session completion
    plugin.timer.state.running = true
    plugin.timer.state.in_break = true
    plugin.timer.state.cycle_count = 1
    
    local status, cycles = plugin.status()
    assert(status == "break", "Should return break status during break")
    assert(cycles == 1, "Should return correct cycle count")
  end)

  it("should track multiple cycles", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    
    -- Simulate multiple completed cycles
    plugin.timer.state.cycle_count = 3
    plugin.timer.state.in_break = true
    
    local status, cycles = plugin.status()
    assert(status == "break", "Should be in break after cycles")
    assert(cycles == 3, "Should track multiple cycles correctly")
  end)

  it("should handle stop with completed cycles", function()
    plugin.setup({ session_minutes = 2, break_minutes = 1 })
    plugin.start()
    
    -- Simulate some completed work
    plugin.timer.state.cycle_count = 2
    plugin.timer.state.in_break = true
    
    plugin.stop()
    assert(plugin.timer.state.running == false, "Should stop timer")
    assert(plugin.timer.state.in_break == false, "Should exit break state")
  end)
end)
