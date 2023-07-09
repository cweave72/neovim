local utils = require('user.utils')

--require('nightfox').load('nightfox')
--require('nightfox').load('nordfox')

--vim.cmd("colorscheme iceberg")
--vim.cmd("colorscheme nordfox")
--vim.cmd("colorscheme nightfox")
vim.cmd("colorscheme sonokai")


-- Load Lua user initializations
require('user.lsp_config')
require('user.telescope.init')
require('user.mappings')

-- nvim-tree setup
require('user.nvim-tree.init')


-- Custom functions
--
function ShowRtp()
    local rtpList = utils.split(vim.o.runtimepath, ',')
    table.insert(rtpList, 1, "-- runtimepath --")
    utils.floatwin(rtpList)
end

-- Set Vim's notify function to use notify-nvim.
vim.notify = require('notify')
