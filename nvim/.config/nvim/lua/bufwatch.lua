
-- lua/bufwatch.lua
local M = {}
M.attached = {}

-- Pick a log file. stdpath("state") is a good place for runtime logs.
local LOG_PATH = vim.fn.stdpath("state") .. "/bufwatch.log"

local function append_log(line)
  local ok, f = pcall(io.open, LOG_PATH, "a")
  if not ok or not f then
    -- Fall back to :messages if file can't be opened
    vim.schedule(function()
      vim.api.nvim_echo({ { "bufwatch: failed to open log: " .. LOG_PATH, "ErrorMsg" } }, true, {})
    end)
    return
  end
  f:write(line, "\n")
  f:close()
end

function M.start(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if M.attached[bufnr] then return end
  M.attached[bufnr] = true

  append_log(("--- attach buf=%d time=%s ---"):format(bufnr, os.date("%Y-%m-%d %H:%M:%S")))

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, buf, changedtick, firstline, lastline, new_lastline, old_byte_size)
      -- Fetch the new text for the replaced region
      local new_lines = vim.api.nvim_buf_get_lines(buf, firstline, new_lastline, true)

      -- Keep the callback light; do file I/O in scheduled context
      vim.schedule(function()
        append_log(("[lines] buf=%d tick=%s replace=[%d,%d) new=[%d,%d) old_bytes=%d new_lines=%d time=%s")
          :format(buf, tostring(changedtick), firstline, lastline, firstline, new_lastline, old_byte_size, #new_lines, os.date("%H:%M:%S")))

        -- Optional: log the actual lines (can be noisy; enable only if you want)
        for i, s in ipairs(new_lines) do
          append_log(("  +%d: %s"):format(firstline + (i - 1), s))
        end
      end)
    end,

    on_changedtick = function(_, buf, changedtick)
      vim.schedule(function()
        append_log(("[tick]  buf=%d tick=%s time=%s"):format(buf, tostring(changedtick), os.date("%H:%M:%S")))
      end)
    end,

    on_detach = function(_, buf)
      M.attached[buf] = nil
      vim.schedule(function()
        append_log(("--- detach buf=%d time=%s ---"):format(buf, os.date("%Y-%m-%d %H:%M:%S")))
      end)
    end,
  })
end

function M.stop(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.attached[bufnr] then return end
  M.attached[bufnr] = nil
  pcall(vim.api.nvim_buf_detach, bufnr)
  append_log(("--- manual detach buf=%d time=%s ---"):format(bufnr, os.date("%Y-%m-%d %H:%M:%S")))
end

function M.log_path()
  return LOG_PATH
end

return M
