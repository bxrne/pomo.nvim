vim.api.nvim_create_user_command("PomoStart", require("pomo").start, {
  nargs = 0,
  desc = "Start a new Pomodoro session",
})

vim.api.nvim_create_user_command("PomoStop", require("pomo").stop, {
  nargs = 0,
  desc = "Stop the current Pomodoro session",
})

vim.api.nvim_create_user_command("PomoReset", require("pomo").reset, {
  nargs = 0,
  desc = "Reset the Pomodoro timer",
})

vim.api.nvim_create_user_command("PomoStatus", function()
  local pomo = require("pomo")
  local status, remaining_or_cycles, cycles = pomo.status()
  
  if status == "running" then
    local minutes = math.floor(remaining_or_cycles / 60)
    local seconds = remaining_or_cycles % 60
    local cycle_text = cycles > 0 and " (Session " .. (cycles + 1) .. ")" or ""
    vim.notify(string.format("🍅 Pomodoro running: %02d:%02d remaining%s", minutes, seconds, cycle_text), vim.log.levels.INFO, { title = "Pomodoro Status" })
  elseif status == "break" then
    vim.notify("☕ Currently on break after " .. remaining_or_cycles .. " session(s)", vim.log.levels.INFO, { title = "Pomodoro Status" })
  else
    local cycle_text = remaining_or_cycles > 0 and " (Completed " .. remaining_or_cycles .. " session(s))" or ""
    vim.notify("Timer is stopped" .. cycle_text, vim.log.levels.INFO, { title = "Pomodoro Status" })
  end
end, {
  nargs = 0,
  desc = "Show current Pomodoro timer status",
})
