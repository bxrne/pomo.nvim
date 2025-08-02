local Timer = require("pomo.timer")

describe("Timer Module", function()
  local timer

  before_each(function()
    timer = Timer
    timer:reset()
  end)

  it("should initialize with correct default state", function()
    assert(timer.state.running == false, "Timer should not be running initially")
    assert(timer.state.start_time == nil, "Start time should be nil initially")
    assert(timer.state.elapsed_time == 0, "Elapsed time should be 0 initially")
    assert(timer.state.duration == 0, "Duration should be 0 initially")
    assert(timer.state.in_break == false, "Should not be in break initially")
    assert(timer.state.cycle_count == 0, "Cycle count should be 0 initially")
  end)

  it("should start timer with correct parameters", function()
    timer:start(25, 5)
    
    assert(timer.state.running == true, "Timer should be running after start")
    assert(timer.state.duration == 25, "Duration should be set correctly")
    assert(timer.state.break_duration == 5, "Break duration should be set correctly")
    assert(timer.state.start_time ~= nil, "Start time should be set")
    assert(timer.state.session_timer_id ~= nil, "Session timer ID should be set")
    assert(timer.state.cycle_count == 0, "Cycle count should start at 0")
  end)

  it("should not start if already running", function()
    timer:start(25, 5)
    local first_start_time = timer.state.start_time
    
    timer:start(30, 10) -- Try to start again with different params
    
    assert(timer.state.start_time == first_start_time, "Start time should not change")
    assert(timer.state.duration == 25, "Duration should remain the same")
  end)

  it("should not start if in break", function()
    timer.state.in_break = true
    timer:start(25, 5)
    
    assert(timer.state.duration == 0, "Duration should not be set when in break")
  end)

  it("should stop timer and clean up", function()
    timer:start(25, 5)
    timer:stop()
    
    assert(timer.state.running == false, "Timer should not be running after stop")
    assert(timer.state.in_break == false, "Should not be in break after stop")
    assert(timer.state.session_timer_id == nil, "Session timer ID should be cleared")
  end)

  it("should reset timer completely", function()
    timer:start(25, 5)
    timer.state.cycle_count = 3 -- Simulate some completed cycles
    timer:reset()
    
    assert(timer.state.running == false, "Timer should not be running after reset")
    assert(timer.state.start_time == nil, "Start time should be nil after reset")
    assert(timer.state.elapsed_time == 0, "Elapsed time should be 0 after reset")
    assert(timer.state.duration == 0, "Duration should be 0 after reset")
    assert(timer.state.break_duration == 0, "Break duration should be 0 after reset")
    assert(timer.state.in_break == false, "Should not be in break after reset")
    assert(timer.state.cycle_count == 0, "Cycle count should be reset to 0")
    assert(timer.state.session_timer_id == nil, "Session timer ID should be nil after reset")
    assert(timer.state.break_timer_id == nil, "Break timer ID should be nil after reset")
  end)

  it("should return correct status when stopped", function()
    local status, cycles = timer:status()
    assert(status == "stopped", "Should return stopped when not running")
    assert(cycles == 0, "Should return 0 cycles when stopped")
  end)

  it("should return correct status when running", function()
    timer:start(25, 5)
    local status, remaining, cycles = timer:status()
    
    assert(status == "running", "Should return running when active")
    assert(remaining ~= nil, "Should return remaining time")
    assert(remaining > 0, "Remaining time should be positive")
    assert(cycles == 0, "Should return 0 cycles when just started")
  end)

  it("should return correct status when in break", function()
    timer.state.in_break = true
    timer.state.cycle_count = 2
    local status, cycles = timer:status()
    
    assert(status == "break", "Should return break when in break mode")
    assert(cycles == 2, "Should return correct cycle count")
  end)

  it("should track cycle count correctly", function()
    timer:start(25, 5)
    
    -- Simulate completing a session (entering break)
    timer.state.in_break = true
    timer.state.cycle_count = 1
    
    local status, cycles = timer:status()
    assert(status == "break", "Should be in break after session")
    assert(cycles == 1, "Should have completed 1 cycle")
  end)

  it("should handle stop during break with cycle count", function()
    timer:start(25, 5)
    timer.state.in_break = true
    timer.state.cycle_count = 3
    
    timer:stop()
    
    assert(timer.state.running == false, "Timer should be stopped")
    assert(timer.state.in_break == false, "Should not be in break after stop")
  end)
end)