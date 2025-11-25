
local function expand_at_trigger()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)

  local trigger = before:match("@(%w+)$")
  if not trigger then return end

  local replacement = nil

  if trigger == "now" then
    replacement = os.date("%H:%M")
  elseif trigger == "time" then
    replacement = os.date("%H:%M:%S")
  elseif trigger == "today" then
    replacement = os.date("%Y-%m-%d")
  elseif trigger == "date" then
    replacement = os.date("%d %b %Y")
  elseif trigger == "color" then
    local h = function() return string.format("%02x", math.random(0, 255)) end
    replacement = "#" .. h() .. h() .. h()
  elseif trigger == "rgb" then
    replacement = string.format("rgb(%d,%d,%d)",
      math.random(0,255), math.random(0,255), math.random(0,255))
  end

  if replacement then
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1  -- 0-based
    local start_col = col - #trigger - 1
    local end_col = col

    -- Schedule the actual text replacement for when it's safe
    vim.schedule(function()
      vim.api.nvim_buf_set_text(0, row, start_col, row, end_col, {replacement})
      -- Place cursor after the inserted text
      vim.api.nvim_win_set_cursor(0, {row + 1, start_col + #replacement})
    end)

    -- Return true so we consume the Tab (or space) if needed
    return true
  end

  return false
end

-- Only activate in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  group = vim.api.nvim_create_augroup("MarkdownAtShortcuts", { clear = true }),
  callback = function()
    -- Expand on Tab
    vim.keymap.set("i", "<Tab>", function()
      if expand_at_trigger() then
        return ""        -- consume Tab
      else
        return "<Tab>"   -- normal Tab behavior
      end
    end, { buffer = true, expr = true })

    -- Optional: also expand on Space (very snappy)
    vim.keymap.set("i", "<Space>", function()
      if expand_at_trigger() then
        return " "       -- still insert the space after replacement
      else
        return "<Space>"
      end
    end, { buffer = true, expr = true })
  end,
})
