" vim:fdm=marker

" You can also do this via vim_configurable.customize in NixOS (but it is done this way for anyone not using nixos at the moment)

""""""""""""""""""""
" Initialization {{{
""""""""""""""""""""

" Return to last edit position when opening files (You want this!)
augroup last_edit
  autocmd!
  autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
augroup END
" Remember info about open buffers on close
set viminfo^=%

"""""""""""""""""
" Keyboard layout
"""""""""""""""""

function! SwapLayout()
  :set langmap=yh,nj,ik,ol,jy,pn,PN,\\;p,\\:P,h\\;,H\\:
  " let mapleader = "\<Backspace>" " use spacebar as a leader key for plugin keystrokes
endfunction

command Swp call SwapLayout()

" }}}
""""""""""""
" Search {{{
""""""""""""

set incsearch " incrementally show search results when searching with / or ?
set hlsearch  " highlight the last search that was done with / or ?
set ignorecase  " Ignore case when searching (this is needed even if smartcase is set)
set smartcase " automatically switch to a case-sensitive search if you use any capital letters (similar to set ignorecase) 

set scrolloff=8 " try to keep 8 lines visible above & below the cursor

" use <space> to end a / or ? search (this does make it hard to search with spaces though, but easier on the pinkie hitting enter)
" this is a more nuanced version of cmap <Space> <CR>
cnoremap <expr> <Space> getcmdtype() == "/" \|\| getcmdtype() == "?" ? "<CR>" : "<Space>"

" enter change mode when search result found (TODO)
" nnoremap c<Space> :s/
" cnoremap <CR> <CR>c

" Quick search hit commands from http://vim.wikia.com/wiki/Copy_or_change_search_hit
" * Type ys to copy the search hit.
" * Type "+ys to copy the hit to the clipboard.
" * Type cs to change the hit. (doesn't currently work)
" * Type gUs to convert the hit to uppercase.
" * Type vs to visually select the hit. If you type another s you will extend the selection to the end of the next hit.
vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
    \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
omap s :normal vs<CR>

" silver searcher using config from https://robots.thoughtbot.com/faster-grepping-in-vim
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
" bind \ (backward slash) to grep shortcut
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap \ :Ag<SPACE>

" open a file in a new gnome-terminal window
function! GnomeTermOpenFile(action, line)
  if a:action == 'h'

    " Get the filename
    "let filename = fnameescape(fnamemodify(a:line, ':p'))
    let filename = shellescape(fnamemodify(a:line, ':p'))

    " Close CtrlP
    call ctrlp#exit()

    " Open the file (See http://askubuntu.com/a/485007)
    silent! execute '!gnome-terminal -x sh -c "vim ' filename '";'

  else

    " Use CtrlP's default file opening function
    call call('ctrlp#acceptfile', [a:action, a:line])

  endif
endfunction
let g:ctrlp_open_func = { 'files': 'GnomeTermOpenFile' }

" }}}
""""""""""
" Tags {{{
""""""""""

set tags=tags;/,codex.tags;/

let g:tagbar_type_haskell = {
    \ 'ctagsbin'  : 'hasktags',
    \ 'ctagsargs' : '-x -c -o-',
    \ 'kinds'     : [
        \  'm:modules:0:1',
        \  'd:data: 0:1',
        \  'd_gadt: data gadt:0:1',
        \  't:type names:0:1',
        \  'nt:new types:0:1',
        \  'c:classes:0:1',
        \  'cons:constructors:1:1',
        \  'c_gadt:constructor gadt:1:1',
        \  'c_a:constructor accessors:1:1',
        \  'ft:function types:1:1',
        \  'fi:function implementations:0:1',
        \  'o:others:0:1'
    \ ],
    \ 'sro'        : '.',
    \ 'kind2scope' : {
        \ 'm' : 'module',
        \ 'c' : 'class',
        \ 'd' : 'data',
        \ 't' : 'type'
    \ },
    \ 'scope2kind' : {
        \ 'module' : 'm',
        \ 'class'  : 'c',
        \ 'data'   : 'd',
        \ 'type'   : 't'
    \ }
\ }

" Generate haskell tags with codex and hscope
map <leader>tg :!codex update --force<CR>:call system("git hscope -X TemplateHaskell")<CR><CR>:call LoadHscope()<CR>

" map <leader>tt :TagbarToggle<CR> " begriff's version
nmap <F8> :TagbarToggle<CR>

" set csprg=~/.haskell-vim-now/bin/hscope
set csprg=hscope
set csto=1 " search codex tags first
set cst
set csverb
nnoremap <silent> <C-\> :cs find c <C-R>=expand("<cword>")<CR><CR>
" Automatically make cscope connections
function! LoadHscope()
  let db = findfile("hscope.out", ".;")
  if (!empty(db))
    let path = strpart(db, 0, match(db, "/hscope.out$"))
    set nocscopeverbose " suppress 'duplicate connection' error
    exe "cs add " . db . " " . path
    set cscopeverbose
  endif
endfunction
au BufEnter /*.hs call LoadHscope()

" }}}
""""""""""""""
" Editing {{{
""""""""""""""

set backspace=indent,eol,start " allow backspace to delete text outside of the current insert mode
" set clipboard=unnamed " use system clipboard for yank/put/delete etc (I'm using leader instead now)
set nostartofline " don't jump to the start-of-line on buffer switches etc

" search with <space><space> or ff
" nmap <Leader><Leader> /
nmap ff /

" reverse search with <s-space> or <space><space><space> or FF
" map <S-Space> ? " set timeoutlen=1000 ttimeoutlen=0
" nmap <Leader><Leader><Leader> ?
nmap FF ?

" insert newlines in normal mode
" nnoremap <C-J> o  " use C-[ instead of Esc to exit insert mode because escape key is already remapped 
" nnoremap <C-J> o<C-[>  " use C-[ instead of Esc to exit insert mode because escape key is already remapped 
" nnoremap <C-K> m`O<Esc>``
nnoremap <Esc>j o<Esc>
nnoremap <Esc>k O<Esc>

" insert spaces in normal mode
nnoremap <Esc>h i <Esc>
nnoremap <Esc>l a <Esc>

" See http://stackoverflow.com/a/37211433/167485
" insert blank lines with <enter> (this is basically an advanced form of nnoremap <CR> i<CR>)
" function! NewlineWithEnter()
"     if !&modifiable
"         execute "normal! \<CR>"
"     else
"         execute "normal! i\<CR>\<ESC>l"
"         execute "startinsert"
"     endif
" endfunction
" nnoremap <CR> :call NewlineWithEnter()<CR>

" allow the . to execute once for each line of a visual selection
vnoremap . :normal .<CR>

" " WARNING: this is unconventional, you may want to leave this commented, especially while learning vim
" " remap h/l, which usually means "left/right one character" to "left/right one word" (equivalent to traditional b/e)
" " I tend to use f and ; or / and n to move inside of lines instead of character motions
" noremap h b
" noremap l e
" " this lets me swap the case for w,e,b using large WORD motions without the need for the <shift> key (taking some strain off of the pinkies)
" noremap w W
" noremap W w
" noremap e E
" noremap E e
" noremap b B
" noremap B b

let g:multi_cursor_exit_from_visual_mode = 0  " dont exit from multiple cursors when leaving visual mode (press Escape twice instead)
let g:multi_cursor_exit_from_insert_mode = 0  " dont exit from multiple cursors when leaving insert mode

" " Remove unwanted whitespace at the end of lines in these files
" autocmd FileType c,cpp,java,php autocmd BufWritePre <buffer> :%s/\s\+$//e

 " Delete trailing white space on save
 func! DeleteTrailingWS()
   exe "normal mz"
   %s/\s\+$//ge
   exe "normal `z"
 endfunc

 augroup   whitespace
   autocmd!
   " autocmd BufWrite *.hs :call DeleteTrailingWS() " (Handled by stylish haskell now)
   autocmd BufWrite *.coffee :call DeleteTrailingWS()
   autocmd BufWrite *.js :call DeleteTrailingWS()
   autocmd BufWrite *.styl :call DeleteTrailingWS()
   autocmd BufWrite *.jade :call DeleteTrailingWS()
 augroup   END

" Alignment {{{

" " Stop Align plugin from forcing its mappings on us
" let g:loaded_AlignMapsPlugin=1
" " Align on equal signs
" map <Leader>a= :Align =<CR>
" " Align on commas
" map <Leader>a, :Align ,<CR>
" " Align on pipes
" map <Leader>a<bar> :Align <bar><CR>
" " Prompt for align character
" map <leader>ap :Align

" Enable some tabular presets for Haskell
let g:haskell_tabular = 1

" (Note: don't add comments after mapping - it breaks)
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Surround shortcuts for visual mode
vmap ) S)
vmap ] S]
" vmap } S} " Let's not remap this one because it hobbles your ability to visually select blocks
vmap - S-
vmap ' S'
vmap " S"
vmap ` S`

" }}}
" }}}
""""""""""""
" Leader {{{
""""""""""""

" use spacebar and backspace interchangably for leader keys (see http://superuser.com/a/693644)
" let mapleader = "\<Space>"
let mapleader = "λ"
map <Space> λ
map <Backspace> λ

" Show the current command in progress (useful for leader keys)
set showcmd

" Swap keyboard layout
nnoremap <Leader>ss :Swp<CR>

" type <Space>o to open a new file:
nnoremap <Leader>o :CtrlP<CR>

" type <Space>w to save file (a lot faster than :w<Enter>)
" also, quit, buffer prev, buffer next, buffer delete, etc
" nnoremap <Leader><Leader> :w<CR>
" nnoremap λλ :w<CR>
nnoremap <Leader><Space> :w<CR>
nnoremap <Leader><Backspace> :w<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>wq :wq<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>bp :bp<CR>
nnoremap <Leader>bn :bn<CR>
nnoremap <Leader>bd :bd<CR>
" nnoremap <Leader> :

nnoremap <Leader>bp :bp<CR>
nnoremap <Leader>bn :bn<CR>
nnoremap <Leader>bd :bd<CR>

" copy & paste to system clipboard with <Space>p and <Space>y:
vnoremap <Leader>y "+y
vnoremap <Leader>d "+d
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P

" enter visual line mode with <Space><Space>:
"nmap <Leader><Leader> V

" }}}
""""""""""""""""""""""""
" Tabs, buffers, etc {{{
""""""""""""""""""""""""

" Gnome-Terminal-like navigation
" nnoremap <C-PageUp>bp :bp<CR> " Doesnt seem to work
" nnoremap <C-PageDown>bn :bn<CR> " Doesnt seem to work
" nnoremap <C-S-t> :tabnew<CR>
" inoremap <C-S-t> <Esc>:tabnew<CR>
" inoremap <C-S-w> <Esc>:tabclose<CR> " needed?

" }}}
"""""""""""""""""
" Status line {{{
"""""""""""""""""

set laststatus=2 " Make the pretty airline status appear on the first buffer
" let g:airline_powerline_fonts = 1 " Use the pretty powerline fonts with the airline status line
let g:airline#extensions#tabline#enabled  = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#branch#enabled   = 1
" let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#ctrlp#enabled    = 1
let g:airline#extensions#hunks#enabled    = 1
let g:airline#extensions#undotree#enabled = 1
let g:airline#extensions#tabline#enabled  = 1
let g:airline_theme                       = 'dark'
let g:airline_symbols                     = {}
let g:airline_symbols.whitespace          = 'Ξ'
let g:airline_left_sep                    = '▶'
let g:airline_right_sep                   = '◀'
let g:airline_symbols.linenr              = '¶ '
let g:airline_symbols.branch              = '⎇ '
let g:airline_symbols.paste               = 'ρ'
let g:airline_detect_modified             = 1
" let g:airline_detect_paste=1 " doesn't work with leader key copy/paste

" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l " Format the status line

" }}}
""""""""""""""""""""
" Line numbering {{{
""""""""""""""""""""

" set number
set relativenumber
set numberwidth=3
highlight LineNr term=bold cterm=NONE ctermfg=Grey ctermbg=DarkMagenta gui=NONE guifg=Grey guibg=DarkMagenta
" highlight CursorLineNr term=bold cterm=NONE ctermfg=Grey ctermbg=DarkMagenta gui=NONE guifg=LightGrey guibg=NONE
"highlight SignColumn term=bold cterm=NONE ctermfg=Grey ctermbg=Black gui=NONE guifg=LightGrey guibg=NONE

" }}}
"""""""""""""""""
" Indentation {{{
"""""""""""""""""

" set tabstop=2     " ?
set softtabstop=2 " ?
set shiftwidth=2  " ?
set smartindent   " ?
set smarttab      " ?
" set autoindent " ?
set expandtab  " ?
" set ruler " ?

" }}}
"""""""""""""""""
" Line breaks {{{
"""""""""""""""""

set showbreak=\ ↪\   " show line breaks (due to wrapping text) with a pretty indicator

" }}}
""""""""""""""""""""
" Mode switching {{{
""""""""""""""""""""

" Kill the damned Ex mode.
nnoremap Q <nop>

" set esckeys " removes the delay after the escape that makes vim feel sluggish exiting visual mode (this will break any sequences using escape in insert mode.)
set timeoutlen=1800 ttimeoutlen=0 " an alternative to esckeys above (but I'm not sure how it works)

" exit insert mode with kj key combination
inoremap kj <ESC>
" noremap jj <ESC>
" inoremap jk <ESC>

" autocomplete in insert mode
" TODO: go to end of word and...
" inoremap jk <C-0>e<C-p>
inoremap jk <C-p>

" undo in insert mode
inoremap jj <C-u>

" prevent escape from moving one character back (interferes with vim-multiple-cursors) 
" let CursorColumnI = 0 "the cursor column position in INSERT
" au InsertEnter * let CursorColumnI = col('.')
" au CursorMovedI * let CursorColumnI = col('.')
" au InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif

" If you find that this event fires too quickly, you can adjust 'updatetime' to suit your needs, but you might want to consider doing so only when you enter insert mode:
au CursorHoldI * stopinsert
au InsertEnter * let updaterestore=&updatetime | set updatetime=5000  " leave insert mode after 5 seconds of inactivity
au InsertCharPre * let updaterestore=&updatetime | set updatetime=1400 " leave insert mode after around 1 or 2 seconds of inactivity after having typed something 
au InsertLeave * let &updatetime=updaterestore

" " Change the color scheme in insert mode (this clears other highlighting if used, so it is not ideal)
" au InsertEnter * colorscheme torte
" au InsertLeave * colorscheme default

" Change the background color to proper black in insert mode
au InsertEnter * hi Normal ctermbg=Black ctermfg=White guibg=DarkGrey
" au InsertEnter * set background=light " can be helpful for preventing the foreground color from changing during highlight
au InsertLeave * hi Normal ctermbg=DarkGrey ctermfg=White ctermbg=NONE guibg=NONE  " note: first changing background to Grey on purpose in order to reset foreground

" }}}
"""""""""""""
" Folding {{{
"""""""""""""

" prevent automatic folding on open in general
set foldlevelstart=99

" " use indentation for folds
" set foldmethod=indent
" set foldnestmax=5
" set foldlevelstart=99
" set foldcolumn=0

" augroup vimrcFold
"   " fold vimrc itself by categories
"   autocmd!
"   autocmd FileType vim set foldmethod=marker
"   autocmd FileType vim set foldlevel=0
" augroup END

" }}}

" Haskell Interrogation {{{
" 
" set completeopt+=longest
" 
" " Use buffer words as default tab completion
" let g:SuperTabDefaultCompletionType = '<c-x><c-p>'
" 
" " But provide (neco-ghc) omnicompletion
" if has("gui_running")
"   imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
" else " no gui
"   if has("unix")
"     inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
"   endif
" endif
" 
" " Show types in completion suggestions
" let g:necoghc_enable_detailed_browse = 1

" Type of expression under cursor
nmap <silent> <leader>ht :GhcModType<CR>
" Insert type of expression under cursor
nmap <silent> <leader>hT :GhcModTypeInsert<CR>
" GHC errors and warnings
" nmap <silent> <leader>hc :SyntasticCheck ghc_mod<CR>

" Resolves ghcmod base directory
" au FileType haskell let g:ghcmod_use_basedir = getcwd()

" Fix path issues from vim.wikia.com/wiki/Set_working_directory_to_the_current_file
" let s:default_path = escape(&path, '\ ') " store default value of 'path'
" Always add the current file's directory to the path and tags list if not
" already there. Add it to the beginning to speed up searches.
" autocmd BufRead *
"       \ let s:tempPath=escape(escape(expand("%:p:h"), ' '), '\ ') |
"       \ exec "set path-=".s:tempPath |
"       \ exec "set path-=".s:default_path |
"       \ exec "set path^=".s:tempPath |
"       \ exec "set path^=".s:default_path

" Haskell Lint
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['haskell'] }
" nmap <silent> <leader>hl :SyntasticCheck hlint<CR>

" Hoogle the word under the cursor
nnoremap <silent> <leader>hh :Hoogle<CR>

" Hoogle and prompt for input
nnoremap <leader>hH :Hoogle

" Hoogle for detailed documentation (e.g. "Functor")
nnoremap <silent> <leader>hi :HoogleInfo<CR>

" Hoogle for detailed documentation and prompt for input
nnoremap <leader>hI :HoogleInfo

" Hoogle, close the Hoogle window
nnoremap <silent> <leader>hz :HoogleClose<CR>

" }}}


" File extensions {{{

set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*/node_modules/* " NodeJS

" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$'
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"   \ 'file': '\v\.(exe|so|dll)$',
"   \ 'link': 'some_bad_symbolic_links',
"   \ }

" }}}
"""""""""""""""""""""""""""""""
" Aesthetics & Highlighting {{{
"""""""""""""""""""""""""""""""

" use 256 colours for e.g. statusline (Use this setting only if your terminal supports 256 colours)
set t_Co=256 

" soften the highlight color (it's a crazy bright yellow by default)
" hi Search cterm=NONE ctermfg=lightgrey ctermbg=black
hi Search cterm=NONE ctermfg=lightmagenta ctermbg=darkmagenta

" turn on syntax highlighting in all files
filetype plugin indent on
syntax on
au BufNewFile,BufRead *.coffee set filetype=coffee " for some reason this seems to be required by coffee-script filetype - don't know why
au BufNewFile,BufRead *.jade set filetype=jade " for some reason this seems to be required by jade filetype - don't know why

" git gutter
let g:gitgutter_override_sign_column_highlight = 0
highlight LineNr term=bold cterm=NONE ctermfg=Grey ctermbg=DarkMagenta gui=NONE guifg=LightGrey guibg=NONE
highlight SignColumn term=bold ctermbg=NONE 

" Show trailing whitespace
set list
" But only interesting whitespace
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
" TODO: Doesn't work well with normal search
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=250
    " echo 'Highlight current word: ON'
    return 1
  endif
endfunction
" call AutoHighlightToggle()

" GHC type highlight
hi ghcmodType ctermbg=blue
let g:ghcmod_type_highlight = 'ghcmodType'

" }}}

" From begriff's haskell-vim-now:

" " General {{{
" 
" 
" 
" " Sets how many lines of history VIM has to remember
" set history=700
" 
" " Set to auto read when a file is changed from the outside
" set autoread
" 
" " With a map leader it's possible to do extra key combinations
" " like <leader>w saves the current file
" let mapleader = ","
" let g:mapleader = ","
" 
" " Leader key timeout
" set tm=2000
" 
" " Allow the normal use of "," by pressing it twice
" noremap ,, ,
" 
" " Use par for prettier line formatting
" set formatprg="PARINIT='rTbgqR B=.,?_A_a Q=_s>|' par\ -w72"
" 
" " Use stylish haskell instead of par for haskell buffers
" autocmd FileType haskell let &formatprg="stylish-haskell"
" 
" " Find custom built ghc-mod, codex etc
" let $PATH = $PATH . ':' . expand("~/.haskell-vim-now/bin")
"
" " }}}
" 
" " Vundle {{{
" 
" set nocompatible
" filetype off
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()
" 
" " let Vundle manage Vundle
" " required!
" Plugin 'gmarik/Vundle.vim'
" 
" " Support bundles
" Plugin 'jgdavey/tslime.vim'
" Plugin 'Shougo/vimproc.vim'
" Plugin 'ervandew/supertab'
" Plugin 'scrooloose/syntastic'
" Plugin 'moll/vim-bbye'
" Plugin 'nathanaelkane/vim-indent-guides'
" Plugin 'vim-scripts/gitignore'
" 
" " Git
" Plugin 'tpope/vim-fugitive'
" Plugin 'int3/vim-extradite'
" 
" " Bars, panels, and files
" Plugin 'scrooloose/nerdtree'
" Plugin 'bling/vim-airline'
" Plugin 'kien/ctrlp.vim'
" Plugin 'majutsushi/tagbar'
" 
" " Text manipulation
" Plugin 'vim-scripts/Align'
" Plugin 'vim-scripts/Gundo'
" Plugin 'tpope/vim-commentary'
" Plugin 'godlygeek/tabular'
" Plugin 'michaeljsmith/vim-indent-object'
" 
" " Allow pane movement to jump out of vim into tmux
" Plugin 'christoomey/vim-tmux-navigator'
" 
" " Haskell
" Plugin 'raichoo/haskell-vim'
" Plugin 'enomsg/vim-haskellConcealPlus'
" Plugin 'eagletmt/ghcmod-vim'
" Plugin 'eagletmt/neco-ghc'
" Plugin 'Twinside/vim-hoogle'
" 
" " Colorscheme
" Plugin 'vim-scripts/wombat256.vim'
" 
" " Custom bundles
" if filereadable(expand("~/.vim.local/bundles.vim"))
"   source ~/.vim.local/bundles.vim
" endif
" 
" call vundle#end()
" 
" " }}}
" 
"  
" " VIM user interface {{{
" 
" " Set 7 lines to the cursor - when moving vertically using j/k
" set so=7
" 
" " Turn on the WiLd menu
" set wildmenu
" " Tab-complete files up to longest unambiguous prefix
" set wildmode=list:longest,full
"  
" 
" " Always show current position
" set ruler
" set number

" " Height of the command bar
" set cmdheight=1
" 
" " Configure backspace so it acts as it should act
" set backspace=eol,start,indent
" set whichwrap+=<,>,h,l
" 
"
" " Highlight search results
" set hlsearch
" 
" " Makes search act like search in modern browsers
" set incsearch
" 
" " Don't redraw while executing macros (good performance config)
" set lazyredraw
" 
" " For regular expressions turn magic on
" set magic
" 
" " Show matching brackets when text indicator is over them
" set showmatch
" " How many tenths of a second to blink when matching brackets
" set mat=2
" 
" " No annoying sound on errors
" set noerrorbells
" set vb t_vb=
" 
" if &term =~ '256color'
"   " disable Background Color Erase (BCE) so that color schemes
"   " render properly when inside 256-color tmux and GNU screen.
"   " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
"   set t_ut=
" endif
" 
" " Force redraw
" map <silent> <leader>r :redraw!<CR>
" 
" " Turn mouse mode on
" nnoremap <leader>ma :set mouse=a<cr>
" 
" " Turn mouse mode off
" nnoremap <leader>mo :set mouse=<cr>
" 
" " Default to mouse mode on
" set mouse=a
" " }}}
" 
" " Colors and Fonts {{{
" 
" try
"   colorscheme wombat256mod
" catch
" endtry
" 
" " Enable syntax highlighting
" syntax enable
" 
" " Adjust signscolumn and syntastic to match wombat
" hi! link SignColumn LineNr
" hi! link SyntasticErrorSign ErrorMsg
" hi! link SyntasticWarningSign WarningMsg
" 
" " Use pleasant but very visible search hilighting
" hi Search ctermfg=white ctermbg=173 cterm=none guifg=#ffffff guibg=#e5786d gui=none
" hi! link Visual Search
" 
" " Enable filetype plugins
" filetype plugin on
" filetype indent on
" 
" " Match wombat colors in nerd tree
" hi Directory guifg=#8ac6f2
" 
" " Searing red very visible cursor
" hi Cursor guibg=red
" 
" " Use same color behind concealed unicode characters
" hi clear Conceal
" 
" " Don't blink normal mode cursor
" set guicursor=n-v-c:block-Cursor
" set guicursor+=n-v-c:blinkon0
" 
" " Set extra options when running in GUI mode
" if has("gui_running")
"   set guioptions-=T
"   set guioptions-=e
"   set guitablabel=%M\ %t
" endif
" set t_Co=256
" 
" " Set utf8 as standard encoding and en_US as the standard language
" set encoding=utf8
" 
" " Use Unix as the standard file type
" set ffs=unix,dos,mac
" 
" " Use large font by default in MacVim
" set gfn=Monaco:h19
" 
" " }}}
" 
" " Files, backups and undo {{{
" 
" " Turn backup off, since most stuff is in Git anyway...
" set nobackup
" set nowb
" set noswapfile
" 
" " Source the vimrc file after saving it
" augroup sourcing
"   autocmd!
"   autocmd bufwritepost .vimrc source $MYVIMRC
" augroup END
" 
" " Open file prompt with current path
" nmap <leader>e :e <C-R>=expand("%:p:h") . '/'<CR>
" 
" " Show undo tree
" nmap <silent> <leader>u :GundoToggle<CR>
" 
" " Fuzzy find files
" nnoremap <silent> <Leader><space> :CtrlP<CR>
" let g:ctrlp_max_files=0
" let g:ctrlp_show_hidden=1
" let g:ctrlp_custom_ignore = { 'dir': '\v[\/](.git|.cabal-sandbox)$' }
" 
" " }}}
" 
" " Text, tab and indent related {{{
" 
" " Use spaces instead of tabs
" set expandtab
" 
" " Be smart when using tabs ;)
" set smarttab
" 
" " 1 tab == 2 spaces
" set shiftwidth=2
" set tabstop=2
" 
" " Linebreak on 500 characters
" set lbr
" set tw=500
" 
" set ai "Auto indent
" set si "Smart indent
" set wrap "Wrap lines
" 
" " Pretty unicode haskell symbols
" let g:haskell_conceal_wide = 1
" let g:haskell_conceal_enumerations = 1
" let hscoptions="𝐒𝐓𝐄𝐌xRtB𝔻"
" 
" " }}}
" 
" " Visual mode related {{{
" 
" " Visual mode pressing * or # searches for the current selection
" " Super useful! From an idea by Michael Naumann
" vnoremap <silent> * :call VisualSelection('f', '')<CR>
" vnoremap <silent> # :call VisualSelection('b', '')<CR>
" 
" " }}}
" 
" " Moving around, tabs, windows and buffers {{{
" 
" " Treat long lines as break lines (useful when moving around in them)
" nnoremap j gj
" nnoremap k gk
" 
" noremap <c-h> <c-w>h
" noremap <c-k> <c-w>k
" noremap <c-j> <c-w>j
" noremap <c-l> <c-w>l
" 
" " Disable highlight when <leader><cr> is pressed
" " but preserve cursor coloring
" nmap <silent> <leader><cr> :noh\|hi Cursor guibg=red<cr>
" augroup haskell
"   autocmd!
"   autocmd FileType haskell map <silent> <leader><cr> :noh<cr>:GhcModTypeClear<cr>:SyntasticReset<cr>
"   autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
" augroup END
" 
" " Open window splits in various places
" nmap <leader>sh :leftabove  vnew<CR>
" nmap <leader>sl :rightbelow vnew<CR>
" nmap <leader>sk :leftabove  new<CR>
" nmap <leader>sj :rightbelow new<CR>
" 
" " Manually create key mappings (to avoid rebinding C-\)
" let g:tmux_navigator_no_mappings = 1
" 
" nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
" nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
" nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
" nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
" 
" " don't close buffers when you aren't displaying them
" set hidden
" 
" " previous buffer, next buffer
" nnoremap <leader>bp :bp<cr>
" nnoremap <leader>bn :bn<cr>
" 
" " close every window in current tabview but the current
" nnoremap <leader>bo <c-w>o
" 
" " delete buffer without closing pane
" noremap <leader>bd :Bd<cr>
" 
" " fuzzy find buffers
" noremap <leader>b<space> :CtrlPBuffer<cr>
" 
" " }}}
" 
" " Status line {{{
" 
" " Always show the status line
" set laststatus=2
" 
" " }}}
" 
" " Editing mappings {{{

" " }}}
" 
" " Spell checking {{{
" 
" " Pressing ,ss will toggle and untoggle spell checking
" map <leader>ss :setlocal spell!<cr>
" 
" " }}}
" 
" " Helper functions {{{
" 
" function! CmdLine(str)
"   exe "menu Foo.Bar :" . a:str
"   emenu Foo.Bar
"   unmenu Foo
" endfunction 
" 
" function! VisualSelection(direction, extra_filter) range
"   let l:saved_reg = @"
"   execute "normal! vgvy"
" 
"   let l:pattern = escape(@", '\\/.*$^~[]')
"   let l:pattern = substitute(l:pattern, "\n$", "", "")
" 
"   if a:direction == 'b'
"     execute "normal ?" . l:pattern . "^M"
"   elseif a:direction == 'gv'
"     call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.' . a:extra_filter)
"   elseif a:direction == 'replace'
"     call CmdLine("%s" . '/'. l:pattern . '/')
"   elseif a:direction == 'f'
"     execute "normal /" . l:pattern . "^M"
"   endif
" 
"   let @/ = l:pattern
"   let @" = l:saved_reg
" endfunction
" 
" " }}}
" 
" " Slime {{{
" 
" vmap <silent> <Leader>rs <Plug>SendSelectionToTmux
" nmap <silent> <Leader>rs <Plug>NormalModeSendToTmux
" nmap <silent> <Leader>rv <Plug>SetTmuxVars
" 
" " }}}
" 
" " NERDTree {{{
" 
" " Close nerdtree after a file is selected
" let NERDTreeQuitOnOpen = 1
" 
" function! IsNERDTreeOpen()
"   return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
" endfunction
" 
" function! ToggleFindNerd()
"   if IsNERDTreeOpen()
"     exec ':NERDTreeToggle'
"   else
"     exec ':NERDTreeFind'
"   endif
" endfunction
" 
" " If nerd tree is closed, find current file, if open, close it
" nmap <silent> <leader>f <ESC>:call ToggleFindNerd()<CR>
" nmap <silent> <leader>F <ESC>:NERDTreeToggle<CR>
" 
" " }}}

" " Git {{{
" 
" let g:extradite_width = 60
" " Hide messy Ggrep output and copen automatically
" function! NonintrusiveGitGrep(term)
"   execute "copen"
"   " Map 't' to open selected item in new tab
"   execute "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
"   execute "silent! Ggrep " . a:term
"   execute "redraw!"
" endfunction
" 
" command! -nargs=1 GGrep call NonintrusiveGitGrep(<q-args>)
" nmap <leader>gs :Gstatus<CR>
" nmap <leader>gg :copen<CR>:GGrep 
" nmap <leader>gl :Extradite!<CR>
" nmap <leader>gd :Gdiff<CR>
" nmap <leader>gb :Gblame<CR>
" 
" function! CommittedFiles()
"   " Clear quickfix list
"   let qf_list = []
"   " Find files committed in HEAD
"   let git_output = system("git diff-tree --no-commit-id --name-only -r HEAD\n")
"   for committed_file in split(git_output, "\n")
"     let qf_item = {'filename': committed_file}
"     call add(qf_list, qf_item)
"   endfor
"   " Fill quickfix list with them
"   call setqflist(qf_list, '')
" endfunction
" 
" " Show list of last-committed files
" nnoremap <silent> <leader>g? :call CommittedFiles()<CR>:copen<CR>
" 
" " }}}
" 
" 
" " Conversion {{{
" 
" function! Pointfree()
"   call setline('.', split(system('pointfree '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" vnoremap <silent> <leader>h. :call Pointfree()<CR>
" 
" function! Pointful()
"   call setline('.', split(system('pointful '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" vnoremap <silent> <leader>h> :call Pointful()<CR>
" 
" " }}}
" 
" " Customization {{{
" 
" if filereadable(expand("~/.vimrc.local"))
"   source ~/.vimrc.local
" endif
" 
" " }}}
