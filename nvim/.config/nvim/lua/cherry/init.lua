local M = {}


local function expand_path(path)
    if path:sub(1,1) == "~" then
        return os.getenv("HOME") .. path:sub(2)
    end
    return path
end


local function win_config()
    local width = math.min(math.floor(vim.o.columns * 0.8), 65)
    local height = math.floor(vim.o.lines * 0.8)

    return {
        relative="editor",
        width=width,
        height=height,
        col = 1,
        row = 1,
        border = "single",
    }
end


local function open_floating_file(target_file)
    -- expand the path
    local expanded_path = expand_path(target_file)

    -- check if the path is real and readable (continue, notify and breakfree)
    if vim.fn.filereadable(expanded_path) == 0 then
       vim.notify("todo file doesn't exist at dir" ..expanded_path, vim.log.levels.ERROR)
        return
    end

    -- i think we made the buffer, and killed the swapfile option
    local buf = vim.fn.bufnr(expanded_path, true)
    if buf == -1 then
        buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(buf, expanded_path)
    end
    vim.bo[buf].swapfile = false

    -- open window
    local win = vim.api.nvim_open_win(buf, true, win_config())


    -- setup keymaps
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        noremap=true,
        silent=true,
        callback = function ()
            if vim.api.nvim_get_option_value("modified", {buf=buf}) then
                vim.notify("save your changes pls", vim.log.levels.WARN)
            else
                vim.api.nvim_win_close(0, true)
            end
        end
    })


end




local function setup_user_commands(opts)
    local target_file = opts.target_file or "todo.md"
    vim.api.nvim_create_user_command("Td", function ()
        -- to be written
        open_floating_file(target_file)
    end , {})
end







M.setup = function (opts)
    setup_user_commands(opts)
end


return M
