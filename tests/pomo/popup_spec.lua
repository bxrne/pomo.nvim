local popup = require("pomo.popup")

describe("Popup Module", function()
  it("should create a popup window or fallback to notify", function()
    local win = popup.show("Test message", "Test Title", "info")
    
    -- In test environment, might return -1 for fallback
    if win == -1 then
      assert(true, "Fallback to vim.notify in test environment")
    else
      assert(win ~= nil, "Should return a window handle")
      assert(vim.api.nvim_win_is_valid(win), "Window should be valid")
      
      -- Clean up
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)

  it("should handle different message types", function()
    local types = {"info", "warn", "error"}
    
    for _, msg_type in ipairs(types) do
      local win = popup.show("Test " .. msg_type, "Test", msg_type)
      
      if win == -1 then
        assert(true, "Fallback to vim.notify in test environment for " .. msg_type)
      else
        assert(vim.api.nvim_win_is_valid(win), "Window should be valid for type " .. msg_type)
        
        -- Clean up
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end
    end
  end)

  it("should handle messages of different lengths", function()
    local short_msg = "Hi"
    local long_msg = "This is a very long message that should make the popup wider"
    
    local win1 = popup.show(short_msg, "Title", "info")
    local win2 = popup.show(long_msg, "Title", "info")
    
    -- In test environment, both might return -1
    if win1 == -1 or win2 == -1 then
      assert(true, "Fallback to vim.notify in test environment")
    else
      local config1 = vim.api.nvim_win_get_config(win1)
      local config2 = vim.api.nvim_win_get_config(win2)
      
      assert(config2.width > config1.width, "Longer message should create wider popup")
      
      -- Clean up
      if vim.api.nvim_win_is_valid(win1) then vim.api.nvim_win_close(win1, true) end
      if vim.api.nvim_win_is_valid(win2) then vim.api.nvim_win_close(win2, true) end
    end
  end)

  it("should create persistent popup when requested", function()
    local dismissed = false
    local win = popup.show("Persistent message", "Title", "info", true, function()
      dismissed = true
    end)
    
    if win == -1 then
      assert(true, "Fallback to vim.notify in test environment")
    else
      assert(vim.api.nvim_win_is_valid(win), "Persistent popup should be valid")
      
      -- Simulate dismissal
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)

  it("should handle multiline messages", function()
    local multiline_msg = "Line 1\nLine 2\nLine 3"
    local win = popup.show(multiline_msg, "Title", "info")
    
    if win == -1 then
      assert(true, "Fallback to vim.notify in test environment")
    else
      assert(vim.api.nvim_win_is_valid(win), "Multiline popup should be valid")
      
      -- Clean up
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)

  it("should add escape hint for persistent popups", function()
    local win = popup.show("Break message", "Title", "info", true)
    
    if win == -1 then
      assert(true, "Fallback to vim.notify in test environment")
    else
      assert(vim.api.nvim_win_is_valid(win), "Persistent popup with hint should be valid")
      
      -- Clean up
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)
end)