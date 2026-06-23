" ── Keymaps ──────────────────────────────────────────────────────────────────

" Quick escape from insert mode
imap jk <Esc>

" Faster vertical scrolling in normal mode
nnoremap <C-j> 10j
nnoremap <C-k> 10k

" ── Display ───────────────────────────────────────────────────────────────────

syntax enable
syntax on

set number          " absolute line numbers
set relativenumber  " relative line numbers (combined with above: hybrid mode)
set showcmd         " show partial command in bottom bar
set showmatch       " highlight matching brackets
set cmdheight=2     " taller command bar, reduces 'press enter' prompts
set scrolloff=5     " keep 5 lines visible above/below cursor when scrolling
set tw=150          " text width — used by auto-formatting commands (gq etc.)
set wildmenu        " enhanced tab-completion menu for : commands

" ── Indentation ───────────────────────────────────────────────────────────────

set tabstop=4       " a tab character renders as 4 spaces wide
set softtabstop=4   " pressing Tab/Backspace moves 4 spaces in insert mode
set sw=4            " shiftwidth — indentation depth for >> << and autoindent
set autoindent      " copy indent from current line when starting a new one
set smartindent     " add an extra indent level after {, etc.

" ── Search ────────────────────────────────────────────────────────────────────

set incsearch       " highlight matches as you type the search pattern
set hlsearch        " keep matches highlighted after search completes

" ── Behaviour ─────────────────────────────────────────────────────────────────

set nostartofline   " keep cursor column when jumping (G, gg, Ctrl-D, etc.)

" Auto-reload vimrc whenever it is saved
au! BufWritePost .vimrc source %
