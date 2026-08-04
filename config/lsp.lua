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

-- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function(ev)
    if not vim.b[ev.buf].diagdisabled then
      vim.diagnostic.enable(false, { bufnr = ev.buf } )
      vim.b[ev.buf].diagdisabled = true
    end
  end,
})

vim.keymap.set('i', '<Esc>', function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].diagdisabled then
    vim.diagnostic.enable(true, { bufnr = buf })
    vim.b[buf].diagdisabled = nil
  end
  vim.cmd('stopinsert')
end, { silent = true })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client then
            -- Enable completion triggered by <c-x><c-o>:
            --vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- enable completion source
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
                autotrigger = true,
                convert = function(item)
                  return { abbr = item.label:gsub("%b()", "") }
              end,
            })
        end

            -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }

        -- Buffer local mappings.
        vim.keymap.set("i", "<c-space>", vim.lsp.completion.get)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'tD', function() open_in_tab(vim.lsp.buf.declaration) end, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'td', function() open_in_tab(vim.lsp.buf.definition) end, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

vim.diagnostic.config({
    underline = true,
    virtual_text = false,
    virtual_lines = {
        current_line = true,
    },
    severity_sort = true,
    float = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '●',
            [vim.diagnostic.severity.WARN] = '▲',
            [vim.diagnostic.severity.HINT] = '◆',
            [vim.diagnostic.severity.INFO] = '■',
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
    },
})

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
-- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
vim.lsp.config("pylsp", {
    settings = {
        pylsp = {
            plugins = {
                -- formatter options
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                -- linter options
                pylint = { enabled = true, executable = "pylint" },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                -- type checker
                pylsp_mypy = { enabled = true },
                -- auto-completion options
                jedi_completion = { fuzzy = true },
                -- import sorting
                pyls_isort = { enabled = true },
            },
        },
    },
    flags = {
        debounce_text_changes = 200,
    },
    capabilities = capabilities,
})
vim.lsp.enable('pylsp')

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_query_ls
-- npm install -g typescript typescript-language-server
vim.lsp.config("ts_ls", {
    capabilities = capabilities
})
vim.lsp.enable("ts_ls")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#svelte
-- npm install -g svelte-language-server
--
-- https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin#usages
-- npm install -g typescript-svelte-plugin
vim.lsp.config("svelte", {
    capabilities = capabilities
})
vim.lsp.enable("svelte")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#tailwindcss
-- npm install -g @tailwindcss/language-server
vim.lsp.config("tailwindcss", {
    filetypes = {"css", "html", "javascript", "typescript", "svelte"},
    capabilities = capabilities
})
vim.lsp.enable("tailwindcss")

-- npm i -g vscode-langservers-extracted
vim.lsp.config("cssls", {
  -- You can add more options here if needed
  filetypes = {"css", "scss", "less", "html"},
  capabilities = capabilities
})
vim.lsp.enable("cssls")

vim.lsp.config("bashls", {
    capabilities = capabilities
})
vim.lsp.enable("bashls")

vim.lsp.config("clangd", {
    capabilities = capabilities,
    cmd = { "clangd", "--enable-config", "--background-index", "--background-index-priority=background", "-j", "1" }
})
vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
    settings = {
        ['rust-analyzer'] = {
            diagnostics = {
                enable = false,
            },
            cargo = {
                extraEnv = {
                    CARGO_HOME = LspConfiguration.cargoHome,
                    APMF_BUILD_ROOT = LspConfiguration.apmfBuildRoot,
                }
            },
            check = {
                extraEnv = {
                    CARGO_HOME = LspConfiguration.cargoHome,
                    APMF_BUILD_ROOT = LspConfiguration.apmfBuildRoot,
                }
            }
        }
    },
    capabilities = capabilities,
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("cmake", {
    capabilities = capabilities,
})
vim.lsp.enable("cmake")

vim.lsp.config("gopls", {
    capabilities = capabilities,
})
vim.lsp.enable("gopls")


vim.lsp.config("lua_ls", {
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
})
vim.lsp.enable("lua_ls")

vim.lsp.config("ltex", {
    capabilities = capabilities,
    settings = {
        ltex = {
            language = "en-GB",
        },
    },
})
vim.lsp.enable("ltex")
