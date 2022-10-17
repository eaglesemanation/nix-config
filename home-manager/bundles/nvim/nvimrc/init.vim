" --- General

let mapleader = " "
let maplocalleader = " "

" Don't limit colors to 256 in terminal
set termguicolors
" Instead of closing buffers when changing view - hide them
set hidden
" Enable mouse in all modes
set mouse=a
" Creates new windows in bottom/right instead of top/left
set splitbelow
set splitright
" Show column with line offsets
set number
set numberwidth=1
set relativenumber
" Always show column with diagnostic signs, even if there are no errors
set signcolumn=yes
" Tab size equal to 4 spaces by default
set tabstop=4
" shiftwidth=tabstop
set shiftwidth=0
" softtabstop=tabstop
set softtabstop=0
" Replace tabs with spaces
set expandtab
" Add russian for spelling check
set spelllang=en,ru
set spell
" Use persistant undo files for recovery
set noswapfile
set nobackup
set undofile
" Keep cursor in the middle of the screen
set scrolloff=999

" --- Plugins
lua require('eaglesemanation')

" --- Mappings
nnoremap <leader>h :wincmd h<cr>
nnoremap <leader>j :wincmd j<cr>
nnoremap <leader>k :wincmd k<cr>
nnoremap <leader>l :wincmd l<cr>
nnoremap <leader>ws :split<cr>
nnoremap <leader>wv :vsplit<cr>
nnoremap <leader>wq :quit<cr>
