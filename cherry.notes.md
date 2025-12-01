
# Agile board
- (nvim) lsp, with autocompletion and everything (estimated time: 60m)
- (nvim) ai, copilot or gemnini auto suggest (estimated time: 60m)
- (nvim) set unwrap for markdown
- (nvim) markdown navigation tools, something i could type and it could take me places
- (general)  themeing colorscheme, dark theme light theme



- autosave, (done) 
- iron.nvim (done)
- adjust telescope to ignore file inside the .git folder
- getting a @today and @now (estimated time: 15m)
- adjust neotree to open on file location with folder expanded
- (tmux) toggle to hide the bar



# Log   

### 2025-11-24
the mornding was a different day, i aint considering both the same day, got back my nvim, somewhat, 
it is kinda different
got stow to work propely
made this repo
committed it to github, and git, now i got a dotfiles in my github. Now i don't have to worry about losing
my neovim, i3 or any of my dotfiles setup, and i can start directly on any computer with my whole setup up,
i just need to clone my github




### 2025-11-25

- iron.nvim, autosave, @-- markdown comments, telescope adjutested to ignore .git folder, neotree to open on file location with folder expanded


- iron.nvim
    - got it done in 34 minutes, (that is actually long)
    - wrote below configs #cbb297
    - 
- autosave
    - got 15 minutes if i can do it
    - done in like 8 mintues, felt really like 3, why does time slow down for 
    - using a config below #56bc6d 
- @today and @now 
    - got it done inside #c014a9

- adjust telescope to ignore file inside the .git folder
    - just adjusted a line that said ignore file types or something with that sense
- adjust neotree to open on file location with folder expanded
    - adjusted 4 lines thanks to grok

- (tmux) toggle to hide the bar
    - easy

- (nvim) toggle to hide the bar
    - easy, ( i need a better way to show the changes that happened)

#cbb297 

``` lua
  return {
      'Vigemus/iron.nvim',
      config = function() 
            local iron = require("iron.core")
            local view = require("iron.view")
            local common = require("iron.fts.common")

            iron.setup {
              config = {
                -- Whether a repl should be discarded or not
                scratch_repl = true,
                -- Your repl definitions come here
                repl_definition = {
                  sh = {
                    -- Can be a table or a function that
                    -- returns a table (see below)
                    command = {"zsh"}
                  },
                  python = {
                    command = { "ipython"  },  -- or { "ipython", "--no-autoindent" }
                    format = common.bracketed_paste_python,
                    block_dividers = { "# %%", "#%%" },
                    env = {PYTHON_BASIC_REPL = "1"} --this is needed for python3.13 and up.
                  },
                  kotlin = {
                      command = "kotlinc-jvm",
                      block_dividers = {"// %%" ,"// %%"}
                  }
                },
                -- set the file type of the newly created repl to ft
                -- bufnr is the buffer id of the REPL and ft is the filetype of the 
                -- language being used for the REPL. 
                repl_filetype = function(bufnr, ft)
                  return ft
                  -- or return a string name such as the following
                  -- return "iron"
                end,
                -- Send selections to the DAP repl if an nvim-dap session is running.
                dap_integration = true,
                -- How the repl window will be displayed
                -- See below for more information
                -- repl_open_cmd = view.bottom(40),

                -- repl_open_cmd can also be an array-style table so that multiple 
                -- repl_open_commands can be given.
                -- When repl_open_cmd is given as a table, the first command given will
                -- be the command that `IronRepl` initially toggles.
                -- Moreover, when repl_open_cmd is a table, each key will automatically
                -- be available as a keymap (see `keymaps` below) with the names 
                -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
                -- For example,
                -- 
                repl_open_cmd = {
                   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
                   view.split.rightbelow("%25")  -- cmd_2: open a repl below
                }

              },
              -- Iron doesn't set keymaps by default anymore.
              -- You can set them here or manually add keymaps to the functions in iron.core
              keymaps = {
                toggle_repl = "<space>rr", -- toggles the repl open and closed.
                -- If repl_open_command is a table as above, then the following keymaps are
                -- available
                -- toggle_repl_with_cmd_1 = "<space>rv",
                -- toggle_repl_with_cmd_2 = "<space>rh",
                restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
                send_motion = "<space>sc",
                visual_send = "<space>sc",
                send_file = "<space>sf",
                send_line = "<space>sl",
                send_paragraph = "<space>sp",
                send_until_cursor = "<space>su",
                send_mark = "<space>sm",
                send_code_block = "<space>sb",
                send_code_block_and_move = "<space>sn",
                mark_motion = "<space>mc",
                mark_visual = "<space>mc",
                remove_mark = "<space>md",
                cr = "<space>s<cr>",
                interrupt = "<space>s<space>",
                exit = "<space>sq",
                clear = "<space>cl",
              },
              -- If the highlight is on, you can change how it looks
              -- For the available options, check nvim_set_hl
              highlight = {
                italic = true
              },
              ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
            }

            -- iron also has a list of commands, see :h iron-commands for all available commands
            vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
            vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
      end
  }

```
- got most of the line from the github repo


#c014a9


``` lua
return {
	"Pocco81/auto-save.nvim",
	config = function()
		 require("auto-save").setup {
			-- your config goes here
			-- or just leave it empty :)
		 }
	end,
}



```

#56bc6d 
``` lua

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

```



# 2025-12-01
- added an alias to android studio
