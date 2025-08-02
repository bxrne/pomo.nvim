---@class Popup
local Popup = {}

-- Create a centered popup window with a message
---@param message string The message to display
---@param title string The title of the popup
---@param type string The type of notification (info, warn, error)
---@param persistent boolean Whether popup should stay visible until dismissed
---@param on_dismiss function Optional callback when popup is dismissed
function Popup.show(message, title, type, persistent, on_dismiss)
  -- Handle test environment where UI may not be available
  local uis = vim.api.nvim_list_uis()
  if not uis or #uis == 0 then
    -- Fallback to vim.notify in test environment
    local level = vim.log.levels.INFO
    if type == "warn" then
      level = vim.log.levels.WARN
    elseif type == "error" then
      level = vim.log.levels.ERROR
    end
    vim.notify(message, level, { title = title })
    return -1 -- Return invalid window handle for tests
  end
  
  local ui = uis[1]
  
  -- Add footnote for persistent popups
  local display_message = message
  if persistent then
    display_message = message .. "\n\nPress <Esc> to stop timer"
  end
  
  local width = math.max(string.len(display_message) + 4, string.len(title) + 4, 50)
  local height = persistent and 8 or 6
  
  -- Calculate center position
  local win_width = ui.width
  local win_height = ui.height
  
  local col = math.floor((win_width - width) / 2)
  local row = math.floor((win_height - height) / 2)
  
  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer content
  local lines = {"╭" .. string.rep("─", width - 2) .. "╮"}
  table.insert(lines, "│" .. string.rep(" ", width - 2) .. "│")
  
  -- Add title
  local title_padding = math.floor((width - string.len(title)) / 2)
  table.insert(lines, "│" .. string.rep(" ", title_padding - 1) .. title .. string.rep(" ", width - title_padding - string.len(title) - 1) .. "│")
  
  -- Add message lines
  for line in display_message:gmatch("[^\n]+") do
    local msg_padding = math.floor((width - string.len(line)) / 2)
    table.insert(lines, "│" .. string.rep(" ", msg_padding - 1) .. line .. string.rep(" ", width - msg_padding - string.len(line) - 1) .. "│")
  end
  
  table.insert(lines, "│" .. string.rep(" ", width - 2) .. "│")
  table.insert(lines, "╰" .. string.rep("─", width - 2) .. "╯")
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  
  -- Create window
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "none",
    focusable = true,
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set highlight based on type
  local hl_group = "Normal"
  if type == "warn" then
    hl_group = "WarningMsg"
  elseif type == "error" then
    hl_group = "ErrorMsg"
  elseif type == "info" then
    hl_group = "Title"
  end
  
  vim.api.nvim_win_set_option(win, "winhl", "Normal:" .. hl_group)
  
  -- Set up keymaps for dismissal
  local function dismiss_popup()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
      if on_dismiss then
        on_dismiss()
      end
    end
  end
  
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = dismiss_popup,
    noremap = true,
    silent = true,
  })
  
  -- For persistent popups, don't auto-close
  if not persistent then
    vim.defer_fn(function()
      dismiss_popup()
    end, 3000)
  end
  
  return win
end

return Popup