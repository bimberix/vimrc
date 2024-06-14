local builtin = require('telescope.builtin')
--vim.keymap.set('n', '<leader>ff', builtin.find_files, {no_ignore = true})
vim.keymap.set('n', '<leader>ff',
    function()
        vim.api.nvim_command('call LeftPaneHideOther("")')
        vim.api.nvim_command('call BottomPaneHideOther("")')
        builtin.find_files({ no_ignore_parent = true, no_ignore = true, hidden = true, follow = true })
    end, {})
vim.keymap.set('n', '<leader>fg',
    function()
        vim.api.nvim_command('call LeftPaneHideOther("")')
        vim.api.nvim_command('call BottomPaneHideOther("")')
        builtin.live_grep({ additional_args = {'--case-sensitive'} })
    end, {})
vim.keymap.set('n', '<leader>fb',
    function()
        vim.api.nvim_command('call LeftPaneHideOther("")')
        vim.api.nvim_command('call BottomPaneHideOther("")')
        builtin.buffers()
    end, {})
vim.keymap.set('n', '<leader>fh',
    function ()
        vim.api.nvim_command('call LeftPaneHideOther("")')
        vim.api.nvim_command('call BottomPaneHideOther("")')
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
