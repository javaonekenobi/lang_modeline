local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("lang_modeline", function()

    local module = require("lang_modeline")

    before_each(function()
        module.emptyLanguages()
    end)

    it("can be required", function()
        require("lang_modeline")
    end)

    it("can add a modeline for language", function()
      local mlines = module.getLanguages()
      assert.are.same({}, mlines)
      module.addLanguage("java","test modeline")
      mlines = module.getLanguages()
      assert.are.same({ java = "test modeline" }, mlines)
    end)

    it("can setup with modelines for languages", function()
      local mlines = module.getLanguages()
      assert.are.same({}, mlines)
      module.setup({
          modelines = { java = "// test modeline" },
      })
      mlines = module.getLanguages()
      assert.are.same({ java = "// test modeline" }, mlines)
    end)

    it("test mocking nvim apis, expected true", function()
        local api = mock(vim.api, true)

        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "ciao", "bello" })

        assert.is_true(module.fixModeline("test modeline"))
        mock.revert(api)
    end)

    it("test mocking nvim apis, expected false", function()
        local api = mock(vim.api, true)

        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "vim:", "vim:" })

        assert.is_not_true(module.fixModeline("test modeline"))
        mock.revert(api)
    end)

    it("mocking apis, no modelines, no filetype expected false", function()
        local api = mock(vim.api, true)

        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "ciao", "bello" })

        -- false because filetype is not java and because I didn't add any modelines in languages
        assert.is_not_true(module.checkModeline())
        mock.revert(api)
    end)

    it("mocking apis, added modelines, still no filetype, expected false", function()
        local api = mock(vim.api, true)

        module.addLanguage("java","test modeline")
        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "ciao", "bello" })

        -- still false because filetype is not java 
        assert.is_not_true(module.checkModeline())
        mock.revert(api)
    end)

    it("mocking apis, filetype set to java, modelines added, expected true", function()
        local api = mock(vim.api, true)

        module.addLanguage("java","test modeline")
        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "ciao", "bello" })
        api.nvim_buf_get_option.returns('java')

        -- this time it should be true
        assert.is_true(module.checkModeline())

        assert.stub(api.nvim_buf_set_lines).was_called_with(0,2,-1,false,{ "test modeline" })
        mock.revert(api)
    end)

    it("mocking apis, filetype set, modelines set, vim: already there, expected false", function()
        local api = mock(vim.api, true)

        module.addLanguage("java","test modeline")
        api.nvim_buf_line_count.returns(2)
        api.nvim_buf_get_lines.returns({ "vim:", "bello" })
        api.nvim_buf_get_option.returns('java')

        -- this time it should be again false because it finds vim: in lines
        assert.is_not_true(module.checkModeline())
        mock.revert(api)
    end)

    it("checking autocmds", function()

        module.setup({
            modelines = { java = "// test modeline" },
        })

        local autocmds = vim.api.nvim_get_autocmds({ group = "irio-modeline", event = { "FileType", "BufWritePost" }, pattern = "*" })

--        print(vim.inspect(autocmds))
        assert.are_equal(2,#autocmds)
    end)

end)


