if &shell =~# 'fish\(_login\)\=$'
  set shell=bash
endif

" Enable modern Vim features not compatible with Vi spec.
set nocompatible

source $VIMRUNTIME/defaults.vim

"""" Vundle setup
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized'
" Plugin 'valloric/youcompleteme'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'taglist.vim'  " from vim.org
Plugin 'moll/vim-bbye'  " more intuitive :Bclose command

" language highlighting
Plugin 'dag/vim-fish'
" Plugin 'kergoth/vim-bitbake'
" Plugin 'nathanalderson/yang.vim'
"
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line



" Enable file type based indent configuration and syntax highlighting.
" Note that when code is pasted via the terminal, vim by default does not detect
" that the code is pasted (as opposed to when using vim's paste mappings), which
" leads to incorrect indentation when indent mode is on.
" To work around this, use ":set paste" / ":set nopaste" to toggle paste mode.
" You can also use a plugin to:
" - enter insert mode with paste (https://github.com/tpope/vim-unimpaired)
" - auto-detect pasting (https://github.com/ConradIrwin/vim-bracketed-paste)
filetype plugin indent on
syntax on

" Assert that we are always using a POSIX shell, so that syntax like $() is
" allowed always.
let g:is_posix = 1

" custom settings
set mouse=ar mousemodel=extend
set ruler
set number
set relativenumber
set clipboard^=unnamed,unnamedplus  " y, d copy to system clipboard, p pastes from
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set showcmd

set incsearch

" show tabs and soft wraps with screen characters
set list listchars=tab:»\ 
set showbreak=↪\ 

" Set colours and long-line indicators
highlight ColorColumn  ctermbg=195 guibg=#ddfffc
highlight CursorColumn ctermbg=193 guibg=#d7ffaf
highlight CursorLine   ctermbg=193 guibg=#d7ffaf

function _SetColorColumn()
  if &textwidth ==? 0
    " No explicit textwidth was set
    set colorcolumn=80,100
  else
    set colorcolumn=+0
  endif
endfunction

" Set up columns once at startup for new buffers, and then run it again after
" the file type handlers have triggered.
call _SetColorColumn()
autocmd BufRead * :call _SetColorColumn()

" syntax folding options
set foldmethod=syntax
set foldnestmax=10
autocmd BufRead * normal zR
" set nofoldenable

" override tab settings for C files
function KernelTabRules()
  setlocal shiftwidth=8 tabstop=8 softtabstop=8 noexpandtab nosmarttab
endfunction

" autocmd FileType c :call KernelTabRules()

" set text width for hg commits
autocmd Filetype hgcommit setlocal textwidth=72

let Tlist_Use_Right_Window = 0
nnoremap <F5> :TlistToggle <Bar> NERDTreeToggle <CR>
" for vertical screen layout, need to automatically C-x J on the taglist
" window, then C-x L on the document window, in order to get nerdtree and
" taglist stacked together to the left of the main editor window
" autocmd BufWritePost * :TlistUpdate

nnoremap <F6> :TlistShowPrototype <CR>

function ToggleTabRules()
  if &tabstop ==? 2
    setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  else
    setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  endif
endfunction

function ToggleForTerminalRawCopy()
  " Toggle &colorcolumn, writing the old value to a buffer-local variable
  if empty(&colorcolumn)
    if !empty(b:orig_colorcolumn)
      let &colorcolumn=b:orig_colorcolumn
    endif
  else
    let b:orig_colorcolumn=&colorcolumn
    set colorcolumn&
  endif

  set number!
  set relativenumber!
endfunction

nnoremap <Leader>q :Bdelete <CR>
nnoremap <Leader>w gqip   " line-wraps according to textwidth

nnoremap <Leader>p :set paste! <CR>
nnoremap <Leader>x :call ToggleForTerminalRawCopy() <CR>
nnoremap <Leader>c :set cursorline! <Bar> set cursorcolumn! <CR>

nnoremap <Leader>4 :call ToggleTabRules() <CR>
nnoremap <Leader>8 :call KernelTabRules() <CR>

if has('gui_running')
  set guifont=Source\ Code\ Pro\ Medium\ 10
endif

