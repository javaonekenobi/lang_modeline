local M = {}

local languages = {}
local verbose = false

-- yeah, it's full of commented debug print, I know... debugger, I know, but I'm a print/log fan, sue me

local group = vim.api.nvim_create_augroup("irio-modeline",{ clear = true })

local getModeline = function()
    return vim.api.nvim_buf_get_lines(0,vim.api.nvim_buf_line_count(0)-1,-1,false);
end

local fixModeline = function (line)
    local modeline = getModeline()

--    print(vim.inspect(modeline))
    if (not string.find(modeline[1],"vim:")) then
--        print("modeline is missing, adding it: "..modeline[1])
--        print("calling set_lines with 0,"..vim.api.nvim_buf_line_count(0)..", -1, false, "..vim.inspect({line}))
        vim.api.nvim_buf_set_lines(0,vim.api.nvim_buf_line_count(0),-1,false,{line})
--        print("verbose is "..tostring(verbose))
        if verbose then
            vim.notify("added modeline to buffer"..vim.api.nvim_buf_get_name(0),vim.log.levels.INFO)
        end
--        print("returning true")
        return true
    end
    return false
end

-- FIXME: adding a wrapper to expose it in order to run tests, I guess I'll have to add tests inside this file to be able to test it if I keep it local
M.fixModeline = function(line)
--    print("calling local fixModeline with "..line)
    local v = fixModeline(line)
--    print("local fixModeline returned "..tostring(v))
    return v
end

M.checkModeline = function()
    local lang = vim.api.nvim_buf_get_option(0,'filetype')
--    print("languages is "..vim.inspect(languages))
    if (languages[lang] ~= nil) then
--        print("we have a modeline for "..lang..":"..languages[lang])
        return fixModeline(languages[lang])
    end
    return false
end

M.addLanguage = function(lang,modeline)
--    print("inserting modeline for lang "..lang.." into languages as "..modeline)
    languages[lang] = modeline
--    M.dumpLanguages()
end

M.removeLanguage = function(lang)
    languages[lang] = nil
end

M.emptyLanguages = function()
    languages = {}
end

M.getLanguages = function()
    return languages
end

M.dumpLanguages = function()
    print("languages: "..vim.inspect(languages))
end

M.init = function()
--    print("creating autocommand")
    local autocmds = vim.api.nvim_get_autocmds({ group = "irio-modeline", event = { "FileType", "BufWritePost" }, pattern = "*" })
    if (#autocmds == 0) then
        vim.api.nvim_create_autocmd(
            { "FileType", "BufWritePost" },
            {
            group = group,
            pattern = "*",
            callback = function()
--                print("autocmd called")
                M.checkModeline()
            end
            }
        )
    end
end

function M.setup(opts)
    opts = opts or {}

    if opts.verbose then
        verbose = opts.verbose
    end

--    print("group is "..group)
--    print("verbose is "..tostring(verbose))
    if opts.modelines then
--        print("opts: "..vim.inspect(opts))
--        print("modelines: "..vim.inspect(opts.modelines))
        for i,j in pairs(opts.modelines) do
            if verbose then
                vim.notify("adding modeline for lang "..i.." as "..j,vim.log.levels.INFO)
            end
            M.addLanguage(i,j)
        end
    end
    M.init()
--    print("end setup")
--    M.dumpLanguages()
end

return M
