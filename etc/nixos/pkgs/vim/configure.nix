{
  pkgs
}:

let
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
in
{
  customRC = 
    let
        base = builtins.readFile ./base.vim;
    in
      ''
          let maplocalleader = "λ"
          " map <Space> λ
          map <Backspace> λ
          " let maplocalleader = "<Backspace>"

          ${base}

          """"""""""""""
          " Haskell {{{
          """"""""""""""
          " Use par for prettier line formatting
          set formatprg="PARINIT='rTbgqR B=.,?_A_a Q=_s>|' par\ -w72"

          " Lint
          function! Ale_linters_haskell_hdevtools2_GetCommand(buffer) abort
             return 'hdevtools check -g -Wall '
              \   .  get(g:, 'hdevtools_options', "")
              \   . ' -p %s %t'
          endfunction
          call ale#linter#Define('haskell', {
          \   'name': 'hdevtools2',
          \   'executable': 'hdevtools',
          \   'command_callback': 'Ale_linters_haskell_hdevtools2_GetCommand',
          \   'callback': 'ale#handlers#HandleGhcFormat',
          \})
          function! Ale_linters_haskell_hlint_Command(buffer) abort
              let l:opts = ""
            if exists("g:ghcmod_hlint_options")
              let l:opts = '"' . join(g:ghcmod_hlint_options, '" "') . '"'
            endif
             return 'hlint '
              \   .  l:opts
              \   . ' --color=never --json -'
          endfunction
          function! Ale_linters_haskell_hlint_Handle(buffer, lines) abort
              let l:errors = json_decode(join(a:lines, ""))
              let l:output = []
              for l:error in l:errors
                  " vcol is Needed to indicate that the column is a character.
                  call add(l:output, {
                  \   'bufnr': a:buffer,
                  \   'lnum': l:error.startLine + 0,
                  \   'vcol': 0,
                  \   'col': l:error.startColumn + 0,
                  \   'text': l:error.severity . ': ' . l:error.hint . '. Found: ' . l:error.from . ' Why not: ' . l:error.to,
                  \   'type': l:error.severity ==# 'Error' ? 'E' : 'W',
                  \})
              endfor
              return l:output
          endfunction
          call ale#linter#Define('haskell', {
          \   'name': 'hlint2',
          \   'executable': 'hlint',
          \   'command_callback': 'Ale_linters_haskell_hlint_Command',
          \   'callback': 'Ale_linters_haskell_hlint_Handle',
          \})

          " }}}
          """"""""""""""
          " Motion {{{
          """"""""""""""
          " beginning/end of line
          nnoremap <Esc>h ^<Esc>
          nnoremap <Esc>l $<Esc>
          " word/character motion
          " noremap H h
          " noremap L l
          " noremap h B
          " noremap l E
          " }}}

          let g:workman_normal_workman = 0
          let g:workman_insert_workman = 0
          let g:workman_normal_qwerty = 0
          let g:workman_insert_qwerty = 0

          " }}}

          let g:ale_linters =
            \ {'haskell': ['hlint2','hdevtools2']
            \ ,'Elm': ['elm-make']
            \ }
          let g:ale_sign_column_always = 1
          "set statusline+=%#warningmsg#
          "set statusline+=%{ALEGetStatusLine()}
          "set statusline+=%*
          "let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
          let g:ale_sign_error = 'e'
          let g:ale_sign_warning = 'w'

          """"""""""""""
          " Buffers {{{
          """"""""""""""
          " See https://unix.stackexchange.com/questions/329641/can-i-remap-ctrl-j-and-ctrl-k-in-vim/329648
          " Note that this conflicts with tmux-navigator
          let g:C_Ctrl_j = 'off'
          nnoremap <silent> <C-j> :bn<CR>
          nnoremap <silent> <C-k> :bp<CR>
          " }}}
      '';
  vam = {
     knownPlugins = pkgs.vimPlugins //
         {
           "vim-workman" = buildVimPlugin {
             name = "vim-workman";
             src = pkgs.fetchFromGitHub {
               owner = "nicwest";
               repo = "vim-workman";
               rev = "955667be18d289528cc2e4239c68ed38499827a9";
               sha256 = "040f64phz2hlngkmp9vkyrqphmljhwj775796kpbpr3ha67ky9hs";
             };
             dependencies = [];
           };

           "vim-airline" = pkgs.vimPlugins.vim-airline // {
             buildInputs = pkgs.vimPlugins.vim-airline.buildInputs ++ [ pkgs.powerline-fonts ];
           };

           # "ale" = buildVimPlugin {
           #   name = "ale";
           #   src = pkgs.fetchFromGitHub {
           #     owner = "w0rp";
           #     repo = "ale";
           #     rev = "10e1545630943aa98320b62f97f79a6f85340e51";
           #     sha256 = "0000000000000000000000000000000000000000000000000000";
           #   };
           #   dependencies = [];
           # };

         };

    pluginDictionaries = [
      { name = "vundle"; }         # Vundle manages bundles (vim plugins)
                                   # Support bundles
                                   # Is this really needed?
      { name = "vim-multiple-cursors"; } 
      # { name = "syntastic"; }       # Warning / Error highlighting 
      { name = "tslime"; }          # ?
      { name = "vimproc"; }         # ?
      # supertab     # ?
      # vim-bbye     # ?
      # vim-indent-guides # ?
      # gitignore      # ?

      # Git
      { name = "fugitive"; }        # ?
      { name = "extradite"; }       # ?

      # Search (TODO: unfortunately, neither of these are available)
      # ack
      # ag

      # Bars, panels, and files
      { name = "vim-nerdtree-tabs"; }  # ? # Begriffs uses scrooloose/nerdtree'
      { name = "vim-airline"; }      # better status line showing you which mode you're in, git info etc (light-weight version of powerline specializing in vim) 

      { name = "ctrlp"; }           # easily open files using ctrl+p
      { name = "tagbar"; }          # ?

      # Text manipulation
      { name = "easy-align"; }      # alignment for comments, operators, etc
      { name = "Gundo"; }           # ?
      { name = "commentary"; }  # ?
      { name = "tabular"; }  # ?
      { name = "surround"; }        # manipulate / add surrounding brackets, quotes, etc
      { name = "gitgutter"; }       # adds git icons (line added, removed, changed etc) to the gutter
      # vim-expand-region # TODO
      # YouCompleteMe # TODO

      # vim-indent-object # ?
      # Allow pane movement to jump out of vim into tmux
      # { name = "tmux-navigator"; }  # ?

      # Colorscheme
      /* wombat256      # grey color-scheme */
      { name = "gruvbox"; }

      # General programming
      # Syntastic

      # Nix
      # vim-addon-nix # does not appear to work well
      { name = "vim-nix"; } 

      # Jade / Stylus
      { name = "vim-jade"; }  # syntax-highlighting + indentation for jade

      # CoffeeScript
      { name = "coffee-script"; }  # syntax-highlighting for coffee-script

      # Elm
      { name = "elm-vim"; } 

      # Haskell
      # haskell-vim # ?
      # { name = "haskellConceal"; }  # converts haskell character set to math characters
                                      # begriffs uses haskellConcealPlus 
      # neco-ghc # ?
      { name = "Hoogle"; }            # quick documentation search for haskell
      # { name = "stylish-haskell"; }  # formatting assistant for haskell code
      { name = "lushtags"; }  # ? (ctags, works with tagbar)
      # devpkgs.vimPlugins.ghcmod # ?
      # ghc-mod-vim # ?

      # Lint
      { name = "ale"; } # Lint for a lot of languages

      # from our own plugin package set
      { name = "vim-workman"; }

      # Local vimrc
      { name = "vim-localvimrc"; }
    ];
  };
}

