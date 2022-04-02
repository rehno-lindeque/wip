    home-manager = {
      users.me = {pkgs, ...}: {
        programs.neovim = {
          extraConfig = ''
            luafile ${./neovim/playground.lua}
          '';
          plugins = with pkgs.vimPlugins; let
          in [
            # Code editing: Delete surrounding brackets, quotes, etc
            # TODO: Does this load slowly
            vim-sandwich
