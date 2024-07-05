local builtin = require('telescope.builtin')
--vim.keymap.set('n', '<leader>ff', builtin.find_files, {no_ignore = true})
vim.keymap.set('n', '<leader>ff',
    function()
        vim.fn.HideOtherPanes(-1)
        builtin.find_files({ no_ignore_parent = true, no_ignore = true, hidden = true, follow = true })
    end, {})
vim.keymap.set('n', '<leader>fg',
    function()
        vim.fn.HideOtherPanes(-1)
        builtin.live_grep({ additional_args = {'--case-sensitive'} })
    end, {})
vim.keymap.set('n', '<leader>fb',
    function()
        vim.fn.HideOtherPanes(-1)
        builtin.buffers()
    end, {})
vim.keymap.set('n', '<leader>fh',
    function ()
        vim.fn.HideOtherPanes(-1)
        builtin.help_tags()
    end, {})

require('telescope').setup {
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        -- ..
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--no-ignore"
        }
    }
}
