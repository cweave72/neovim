local USER = vim.fn.expand('$USER')


-- helper for normal-mode mappings
local buf_nmap = function(key, cmd)
    vim.api.nvim_buf_set_keymap(0, 'n', key, "<cmd>".. cmd .. "<cr>", {
        noremap = true,
        silent = true,
    })
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    print("LSP started")
    local function buf_opt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_nmap('gD',        'lua vim.lsp.buf.declaration()')
    buf_nmap('gd',        'lua vim.lsp.buf.definition()')
    buf_nmap('gi',        'lua vim.lsp.buf.implementation()')
    buf_nmap('gr',        'lua vim.lsp.buf.references()')
    buf_nmap('K',         'lua vim.lsp.buf.hover()')
    buf_nmap('<C-k>',     'lua vim.lsp.buf.signature_help()')
    buf_nmap('<space>D',  'lua vim.lsp.buf.type_definition()')
    buf_nmap('<space>ca', 'lua vim.lsp.buf.code_action()')
    buf_nmap('<space>e',  'lua vim.diagnostic.open_float()')
    buf_nmap('[d',        'lua vim.diagnostic.goto_prev()')
    buf_nmap(']d',        'lua vim.diagnostic.goto_next()')
    buf_nmap('<space>q',  'lua vim.diagnostic.setloclist()')
    buf_nmap('<space>f',  'lua vim.lsp.buf.formatting()')
end


-- Completion setup
vim.o.completeopt = 'menu,menuone,noselect,noinsert,preview'

-- nvim-cmp setup
local nvim_lsp = require('lspconfig')
local cmp = require('cmp')

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
    }),
    completion = {
        keyword_length = 1,
    },
    sources = cmp.config.sources({
        -- Order implies priority here:
        { name = 'nvim_lsp' },
        { name = 'buffer' , keyword_length = 3 },
        --{ name = 'nvim_lua' },
        --{ name = 'luasnip' },
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    experimental = {
        native_menu = false,
    }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

--local utils = require('user.utils')
--utils.debug_print(cmp.setup)

-- Sumneko Lua LSP
--
local sumneko_root_path = "/home/" .. USER .. "/.local/lua-language-server"
local sumneko_binary    = "/home/" .. USER .. "/.local/lua-language-server/bin/lua-language-server"


nvim_lsp.lua_ls.setup {
    on_attach = on_attach,
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';')
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                }
            }
        }
    }
}

-- Python ruff 
--
nvim_lsp.ruff.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
       settings = {
         -- Any extra CLI arguments for `ruff` go here.
         lineLength = 80,
         fixAll = true,
         organizeImports = true,
         format = {
            preview = true,
         },
         lint = {
            enable = true,
            preview = true,
            ignore = {},
            extendIgnore = {},
         },
         args = {},
       }
    },
    commands = {
        RuffAutofix = {
            function()
                vim.lsp.buf.execute_command {
                    command = 'ruff.applyAutofix',
                    arguments = {
                        { uri = vim.uri_from_bufnr(0) },
                    },
                }
            end,
            description = 'Ruff: Fix all auto-fixable problems',
        },
        RuffFormat = {
            function()
                vim.lsp.buf.execute_command {
                    command = 'ruff.applyFormat',
                    arguments = {
                        { uri = vim.uri_from_bufnr(0), version = 0 },
                    },
                }
            end,
            description = 'Ruff: Run formatter',
        },
        RuffOrganizeImports = {
            function()
                vim.lsp.buf.execute_command {
                    command = 'ruff.applyOrganizeImports',
                    arguments = {
                        { uri = vim.uri_from_bufnr(0) },
                    },
                }
            end,
            description = 'Ruff: Format imports',
        },
    },
}

-- Python LSP (pyls)
--
--nvim_lsp.pylsp.setup {
--    on_attach = on_attach,
--    capabilities = capabilities,
--    cmd = {'/usr/local/bin/pyls'},
--    settings = {
--        pyls = {
--            plugins = {
--                pycodestyle = {
--                    enabled = true,
--                    ignore = {"E203", "E221", "E226", "E731", "E261", "E265", "E501"},
--                },
--                pylint = {
--                    enabled = false,
--                }
--            },
--        }
--    }
--}

-- C (ccls)
--
--nvim_lsp.ccls.setup {
--    on_attach = on_attach,
--    cmd = { "ccls" },
--    init_options = {
--        compilationDatabaseDirectory = "build",
--        index = {
--            threads = 0,
--        },
--        clang = {
--            excludeArgs = { "-frounding-math" },
--        },
--    }
--}

-- bash
--
--nvim_lsp.bashls.setup {
--    on_attach = on_attach,
--    cmd = { "bash-language-server", "start" },
--    cmd_env = {
--        GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)"
--    },
--    filetypes = { "sh" },
--    single_file_support = true,
--}
