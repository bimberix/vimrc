-- https://github.com/neovim/nvim-lspconfig#suggested-configuration
--
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

function open_in_tab(cmd)
    local curr_tab = vim.api.nvim_tabpage_get_number(0)
    local curr_buf = vim.api.nvim_buf_get_number(0)

    cmd(params, { reuse_win = true })

    vim.wait(200, function() end)
    if not (0 == vim.fn.IsBufQuickFix(vim.fn.bufnr())) then
        vim.api.nvim_command('set modifiable')
        vim.fn.HideOtherPanes(vim.fn.bufnr())
        vim.api.nvim_command('resize ' .. vim.api.nvim_eval('g:bottomPaneHeight'))
    else
        local new_tab = vim.api.nvim_tabpage_get_number(0)
        local new_buf = vim.api.nvim_buf_get_number(0)
        if (curr_tab == new_tab) and not (curr_buf == new_buf) then
            -- Create a new tab for the original file
            vim.api.nvim_command('-tabnew %')

            -- Restore the cursor position
            vim.api.nvim_command('b ' .. curr_buf)

            -- Switch to the original tab
            vim.api.nvim_command('normal! gt')
        end
    end
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', function() open_in_tab(vim.lsp.buf.declaration) end, opts)
        --vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gd', function() open_in_tab(vim.lsp.buf.definition) end, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', function() open_in_tab(vim.lsp.buf.implementation) end, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', function() open_in_tab(vim.lsp.buf.references) end, opts)
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

-- https://github.com/hrsh7th/nvim-cmp#recommended-configuration


-- Set up nvim-cmp.
local cmp = require 'cmp'

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
luasnip.config.set_config({ history = true, updateevents = "TextChanged,TextChangedI" })
--require("luasnip.loaders.from_vscode").load()
require("luasnip.loaders.from_vscode").lazy_load()
--require("luasnip.loaders.from_snipmate").lazy_load()


cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    view = {
        entries = "custom" -- can be "custom", "wildmenu" or "native"
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        --['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    }),
    completion = { completeopt = "menu,menuone,noinsert" },
    experimental = { ghost_text = false },
})

--[[
require("nvim-autopairs").setup()
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
--local cmp = require("cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
--
--cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"
]]

-- lsp highlight

local highlight_cfg = {
    debug = false,                                              -- set to true to enable debug logging
    log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
    -- default is  ~/.cache/nvim/lsp_signature.log
    verbose = false,                                            -- show debug line number

    bind = true,                                                -- This is mandatory, otherwise border config won't get registered.
    -- If you want to hook lspsaga or other signature handler, pls set to false
    doc_lines = 10,                                             -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    -- set to 0 if you DO NOT want any API comments be shown
    -- This setting only take effect in insert mode, it does not affect signature help in normal
    -- mode, 10 by default

    max_height = 12,                        -- max height of signature floating_window
    max_width = 80,                         -- max_width of signature floating_window
    noice = false,                          -- set to true if you using noice to render markdown
    wrap = true,                            -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long

    floating_window = true,                 -- show hint in a floating window, set to false for virtual text only mode

    floating_window_above_cur_line = false, -- try to place the floating above the current line when possible Note:
    -- will set to true when fully tested, set to false will use whichever side has more space
    -- this setting will be helpful if you do not want the PUM and floating win overlap

    floating_window_off_x = -1, -- adjust float windows x position.
    -- can be either a number or function
    floating_window_off_y = -2, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
    -- can be either number or function, see examples

    close_timeout = 4000,                         -- close floating window after ms when laster parameter is entered
    fix_pos = false,                              -- set to true, the floating window will not auto-close until finish all parameters
    hint_enable = false,                          -- virtual hint enable
    hint_prefix = "",                             -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
    hint_scheme = "String",
    hint_inline = function() return false end,    -- should the hint be inline(nvim 0.10 only)?  default false
    hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
    handler_opts = {
        border = "none"                           -- double, rounded, single, shadow, none, or a table of borders
    },

    always_trigger = false,                  -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

    auto_close_after = nil,                  -- autoclose signature float win after x sec, disabled if nil.
    extra_trigger_chars = {},                -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    zindex = 200,                            -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

    padding = '',                            -- character to pad on left and right of signature can be ' ', or '|'  etc

    transparency = nil,                      -- disabled by default, allow floating win transparent value 1~100
    shadow_blend = 36,                       -- if you using shadow as border use this set the opacity
    shadow_guibg = 'Black',                  -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    timer_interval = 200,                    -- default timer check interval set to lower value if you want to reduce latency
    toggle_key = '<C-space>',                -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    toggle_key_flip_floatwin_setting = true, -- true: toggle float setting after toggle key pressed

    select_signature_key = nil,              -- cycle to next signature, e.g. '<M-n>' function overloading
    move_cursor_key = nil,                   -- imap, use nvim_set_current_win to move cursor between current win and floating
}

-- recommended:
require 'lsp_signature'.setup(highlight_cfg) -- no need to specify bufnr if you don't use toggle_key

-- signs

local signs = { Error = "●", Warn = "▲", Hint = "◆", Info = "■" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_command('hi DiagnosticError ctermfg=202')

vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
        source = "always", -- Or "if_many"
    },
})

--quickfix fianostics
--require("diaglist").init({
    ---- optional settings
    ---- below are defaults
    --debug = false, 

    ---- increase for noisy servers
    --debounce_ms = 300,
--})

--Show line diagnostics automatically in hover window
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- language servers
local lspcfg = require "lspconfig"

-- Set up lspconfig.
--local capabilities = require('cmp_nvim_lsp').default_capabilities()
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md


-- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
lspcfg.pylsp.setup {
    capabilities = capabilities,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = { 'W391' },
                    maxLineLength = 120
                },
                autopep8 = {
                    enabled = false,
                },
            }
        }
    }
}

lspcfg.bashls.setup {
    capabilities = capabilities
}
lspcfg.clangd.setup {
    capabilities = capabilities,
    cmd = { "clangd", "--enable-config" }
}

lspcfg.rust_analyzer.setup{
      settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      },
      cargo = {
        extraEnv = {
            CARGO_HOME = "",
            APMF_BUILD_ROOT = ""
        }
      },
      check = {
        extraEnv = {
            CARGO_HOME = "",
            APMF_BUILD_ROOT = ""
        }
      }
    }
  }
}

require'lspconfig'.cmake.setup{}

lspcfg.gopls.setup {
    capabilities = capabilities,
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    root_dir = lspcfg.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}
lspcfg.lua_ls.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {
                    'vim',
                    'require'
                },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

lspcfg.ltex.setup {
    capabilities = capabilities,
    settings = {
        ltex = {
            language = "en-GB",
        },
    },
}
