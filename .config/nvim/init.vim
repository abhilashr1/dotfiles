call plug#begin()

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

Plug 'preservim/nerdtree'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'jistr/vim-nerdtree-tabs'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'vim-test/vim-test'
Plug 'dense-analysis/ale'

Plug 'tpope/vim-fugitive'
Plug 'EdenEast/nightfox.nvim'
Plug 'yamatsum/nvim-cursorline'

Plug 'terrortylor/nvim-comment'

Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'webdevel/tabulous'
call plug#end()


" Ignore dist, node_modules and .git files in search
let $FZF_DEFAULT_COMMAND='find . \( -name node_modules -o -name .git -o -name dist \) -prune -o -print'

" Open NERDTree automatically in PWD
let g:nerdtree_tabs_open_on_gui_startup=1
let g:nerdtree_tabs_open_on_console_startup=1

" Yank to clipboard
set clipboard+=unnamedplus

" Git blame

" Linting
let g:ale_fixers={'javascript': ['prettier', 'eslint'], 'typescript': ['prettier', 'eslint']}
let g:ale_fix_on_save=1
let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1

" Open NERDTree in new tab
autocmd BufWinEnter * NERDTreeMirrorOpen
set completeopt=menu,menuone,noselect

lua << END
require('lualine').setup()

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "typescript", "go", "javascript", "ruby" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    additional_vim_regex_highlighting = false
  }
}
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)

  --[[
  Using LSP Saga methods instead of the default LSP one

  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<C-a>', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  --]]

  client.server_capabilities.documentFormattingProvider = true

end

local cmp = require('cmp')
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, 
    }, {
      { name = 'buffer' },
    })
  })

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities
} 
nvim_lsp.solargraph.setup {
  on_attach = on_attach,
  capabilities = capabilities
}
nvim_lsp.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

require('nvim-cursorline').setup {
  cursorline = {
    enable = true,
    timeout = 1000,
    number = false,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}

require('nvim_comment').setup({comment_empty = false})

-- LSP Saga

local keymap = vim.keymap.set
local saga = require('lspsaga')

saga.init_lsp_saga({
  saga_winblend = 0,
})

-- Lsp finder find the symbol definition implement reference
-- if there is no implement it will hide
-- when you use action in finder like open vsplit then you can
-- use <C-t> to jump back
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

-- Code action
keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })

-- Rename
keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
-- keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

-- Show line diagnostics
keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

-- Show cursor diagnostic
keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

-- Diagnsotic jump can use `<c-o>` to jump back
keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })

-- Only jump to error
keymap("n", "[E", function()
  require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })
keymap("n", "]E", function()
  require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true })

-- Outline
keymap("n","<leader>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })

-- Hover Doc
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

-- Float terminal
keymap("n", "<leader>t", "<cmd>Lspsaga open_floaterm<CR>", { silent = true })

-- close floaterm
keymap("t", "<leader>t", [[<C-\><C-n><cmd>Lspsaga close_floaterm<CR>]], { silent = true })

--- Indent blank lines

require("indent_blankline").setup {
    -- for example, context is off by default, use this to turn it on
    show_current_context = true,
    show_current_context_start = true,
}

require("nvim-autopairs").setup {}

END

colorscheme nightfox

" Key mappings
nnoremap <C-f> <cmd>Telescope find_files<cr>
nnoremap <C-s> <cmd>Telescope live_grep<cr>
nnoremap <C-\> :NERDTreeFocusToggle<CR>
map <leader>r :NERDTreeFind<cr>

noremap <leader>1 1gt<cr>
noremap <leader>2 2gt<cr>
noremap <leader>3 3gt<cr>
noremap <leader>4 4gt<cr>
noremap <leader>5 5gt<cr>
noremap <leader>6 6gt<cr>
noremap <leader>7 7gt<cr>
noremap <leader>8 8gt<cr>
noremap <leader>9 9gt<cr>

nnoremap <silent> g? <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>

" Autofix entire buffer with eslint_d:
nnoremap <leader>f mF:%!eslint_d --stdin --fix-to-stdout<CR>`F

" Git blame
nnoremap <leader>b :G blame<CR>

" Navigation
nnoremap <C-d> 5j<CR>
nnoremap <C-u> 5k<CR>

" Relative Line Numbers
:set number relativenumber
:set nu rnu

" Cursor Line
:set cursorline

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " Expand TABs to spaces

" Gofmt on save
function! CustomGoFmt()
  let file = expand('%')
  silent execute "!gofmt -w " . file
  edit!
endfunction

command! CustomGoFmt call CustomGoFmt()
augroup go_autocmd
  autocmd BufWritePost *.go CustomGoFmt
augroup END
