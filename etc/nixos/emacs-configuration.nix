{ config
, pkgs
, ... 
}:

let emacs-custom = pkgs.emacsWithPackages
      (with pkgs.emacsPackages; with pkgs.emacsPackagesNg; [
        # auctex
        # company
        # company-ghc
        # diminish
        helm  # Incremental completion

        # SCM integration
        magit
        # git-auto-commit-mode
        # git-timemachine

        # rainbow-delimiters
        # undo-tree
        # use-package

        # Editing
        god-mode
        evil
        evil-god-state
        # evil-indent-textobject
        # evil-leader
        # evil-surround
        # org-plus-contrib # org is the basic package

        # Programming languages
        haskell-mode
        # #ghc-mod
        coffee
        # markdown-mode
        # nix-mode # doesn't seem to be available yet?
        
        # Testing / debugging
        # flycheck

        # Themes
        # moe-theme
        monokai-theme
        # zenburn-theme
        # deviant-theme
        # color-theme-sanityinc-tomorrow

        # Unknown
        # calfw
        # notmuch
      ]);
    startEmacsServer = pkgs.writeScript "start-emacs-server"
      ''
          #!/bin/sh
          . ${config.system.build.setEnvironment}
          ${emacs-custom}/bin/emacs --daemon
      '';
in
{
  environment.systemPackages = with pkgs // pkgs.emacs24PackagesNg ; [ 
    emacs-custom 
  ];

  systemd.user.services.emacs = {
    description = "Emacs Daemon";
    enable = true;
    # environment.SSH_AUTH_SOCK = "%h/.gnupg/S.gpg-agent.ssh";
    serviceConfig = {
      Type = "forking";
      ExecStart = "${startEmacsServer}";
      ExecStop = "${emacs-custom}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };
    wantedBy = [ "default.target" ];
  };
}
