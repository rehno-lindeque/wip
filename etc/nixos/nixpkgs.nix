{ pkgs
, ...
}:

{
  nixpkgs = {
    config = {
      # Enable unfree packages
      allowUnfree = true;

      # Overrides
      packageOverrides = pkgs: with pkgs; {
        # shorthands
        vim-multiple-cursors = pkgs.vimPlugins.vim-multiple-cursors;    # multiple cursors for vim (similar to sublime multiple-cursors)
        vim-nerdtree-tabs = pkgs.vimPlugins.vim-nerdtree-tabs;          #
        ghc-mod-vim = pkgs.vimPlugins.ghc-mod-vim;
      };

    };
  };
}
