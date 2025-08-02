# 🍅 pomo.nvim

A beautiful, feature-rich Pomodoro Technique timer plugin for Neovim that helps you stay focused and productive during coding sessions.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bxrne/pomo.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

## ✨ Features

- 🔄 **Infinite Cycling**: Automatically cycles between work sessions and breaks until you stop
- 🎯 **Prominent Notifications**: Centered popup windows instead of basic vim.notify
- ⏸️ **Interactive Breaks**: Persistent break popups with escape-to-stop functionality
- 📊 **Session Tracking**: Track completed sessions and current progress
- ⚡ **Zero Configuration**: Works out of the box with sensible defaults
- 🎨 **Statusline Integration**: Easy integration with your statusline
- 🧪 **Fully Tested**: Comprehensive test coverage with 29+ tests

## 🚀 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "github.com/bxrne/pomo.nvim",
  config = function()
    require("pomo").setup({
      session_minutes = 25,  -- Work session duration
      break_minutes = 5,     -- Break duration
    })
  end,
}
```

Then in your `init.lua`:
```lua
require("pomo").setup()
```

## ⚙️ Configuration

```lua
require("pomo").setup({
  session_minutes = 25,  -- Default: 25 minutes
  break_minutes = 5,     -- Default: 5 minutes
})
```

## 🎮 Usage

### Commands

| Command | Description |
|---------|-------------|
| `:PomoStart` | Start an infinite Pomodoro cycle |
| `:PomoStop` | Stop the current cycle completely |
| `:PomoReset` | Reset timer and clear all progress |
| `:PomoStatus` | Show current status and progress |

### How It Works

1. **Start**: Run `:PomoStart` to begin your productivity cycle
2. **Work**: Focus during your session (default: 25 minutes)
3. **Break Notice**: When the session ends, a persistent popup appears:
   ```
   ╭──────────────────────────────────────────────────╮
   │                 Pomodoro Timer                   │
   │     🍅 Session 3 complete!                       │
   │     Take a 5 minute break                        │
   │                                                  │
   │           Press <Esc> to stop timer              │
   ╰──────────────────────────────────────────────────╯
   ```
4. **Break Options**:
   - **Wait**: Break timer expires → Next session starts automatically
   - **Escape**: Press `<Esc>` → Entire timer stops
5. **Infinite Loop**: Continues until you manually stop

## 🔧 API

```lua
local pomo = require("pomo")

-- Start infinite session cycle
pomo.start()

-- Stop the cycle
pomo.stop()

-- Reset everything
pomo.reset()

-- Get status information
local status, remaining, cycles = pomo.status()
-- status: "stopped" | "running" | "break"
-- remaining: seconds remaining (when running) or cycle count
-- cycles: current cycle count (when running)
```

## 🎨 Statusline Integration

### Simple Example
```lua
local function pomo_status()
  local status, remaining, cycles = require("pomo").status()
  
  if status == "running" then
    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60
    return string.format("🍅 S%d %02d:%02d", cycles + 1, minutes, seconds)
  elseif status == "break" then
    return string.format("☕ Break (after %d sessions)", cycles)
  else
    return cycles > 0 and string.format("✅ %d sessions", cycles) or ""
  end
end
```

### With [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
```lua
require('lualine').setup {
  sections = {
    lualine_x = { pomo_status, 'encoding', 'fileformat', 'filetype' },
  }
}
```

## ⌨️ Keybindings

```lua
vim.keymap.set("n", "<leader>ps", function() require("pomo").start() end, { desc = "Start Pomodoro" })
vim.keymap.set("n", "<leader>pt", function() require("pomo").stop() end, { desc = "Stop Pomodoro" })
vim.keymap.set("n", "<leader>pr", function() require("pomo").reset() end, { desc = "Reset Pomodoro" })
vim.keymap.set("n", "<leader>pi", ":PomoStatus<CR>", { desc = "Pomodoro Status" })
```

## 🎯 Advanced Usage

### Automatic Environment Setup
```lua
-- Auto-adjust environment during sessions
vim.api.nvim_create_autocmd("User", {
  pattern = "PomoSessionStart",
  callback = function()
    vim.opt.spell = false
    vim.cmd("silent! NoNeckPain")  -- Enable focus mode
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "PomoBreakStart", 
  callback = function()
    vim.cmd("silent! wall")  -- Save all files
  end,
})
```

### Session Logging
```lua
-- Log completed sessions
vim.keymap.set("n", "<leader>pt", function()
  local status, cycles = require("pomo").status()
  if cycles > 0 then
    print("Completed " .. cycles .. " productive sessions! 🎉")
  end
  require("pomo").stop()
end, { desc = "Stop and celebrate Pomodoro sessions" })
```

## 🧪 Testing

```bash
# Run all tests
make test

# Tests are comprehensive with 29+ test cases covering:
# - Timer functionality and infinite cycling
# - Popup behavior and persistence
# - Session tracking and status reporting
# - Integration between components
```

## 🔍 Troubleshooting

### Popups Not Appearing
- Ensure Neovim >= 0.8.0
- Check for plugin conflicts with popup windows

### Break Popup Not Responding to Escape
- Verify the popup has focus (should grab automatically)
- Check for conflicting `<Esc>` keymaps with `:verbose map <Esc>`

### Timer Not Cycling
- Check for Lua errors with `:messages`
- Ensure you're using `:PomoStart` not just `require("pomo").start()`

## 📚 Documentation

Access comprehensive help documentation:
```vim
:help pomo
```

Inspired by the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique) by Francesco Cirillo
