{ pkgs
, ...
}:

{
  nixpkgs =
    {
      config =
        {
          # Enable unfree packages
          allowUnfree = true;

          # Overrides
          packageOverrides = super: with super;
            {
              # shorthands
              # vim-multiple-cursors = vimPlugins.vim-multiple-cursors;    # multiple cursors for vim (similar to sublime multiple-cursors)
              # vim-nerdtree-tabs = vimPlugins.vim-nerdtree-tabs;          #
              # ghc-mod-vim = vimPlugins.ghc-mod-vim;

              me-vim = pkgs.vim_configurable.customize
                        {
                          vimrcConfig = import ./pkgs/vim/configure.nix { pkgs = pkgs; };
                          name = "vim";
                        };

             # All patches, services, etc from https://aur.archlinux.org/pkgbase/linux-macbook/?comments=all
             # nix-prefetch remote https://aur.archlinux.org/linux-macbook.git
             arch-linux-macbook = pkgs.fetchgit {
                url = "https://aur.archlinux.org/linux-macbook.git";
                /* sha256 = "091kvsrsrzwsy1905n85g1bzzf23dcy3rgcvq3ng6nzxhg7a9yq5"; */
                /* rev = "1c00d30fae794c263c9a5f274e5a704ab329343c"; */
                "rev" = "b216fa21a2b21696b68fd37964a2a57bf6171125";
                "sha256" = "17g8kfgp9ifd876jraa4cy5279p55953wv7hcs2581w6w75xrxfr";
              };

              # neovim = neovim.override
              #   {
              #     vimAlias = true;
              #     configure = import ./pkgs/vim/configure.nix { pkgs = super; };
              #   };

              # customizations
              /* yi-custom = import ./yi-custom.nix { pkgs = super; }; */
              ghc-custom = import ./ghc-custom.nix { pkgs = super; };

              # scripts
              # From https://wiki.archlinux.org/index.php/MacBookPro11,x#Powersave and https://gist.github.com/anonymous/9c9d45c4818e3086ceca
              remove-usb-device = pkgs.writeScript "remove-usb-device"
                                    ''
                                    #!/bin/sh
                                    logger -p info "$0 executed."
                                    if [ "$#" -eq 2 ];then
                                      removevendorid=$1
                                      removeproductid=$2
                                      usbpath="/sys/bus/usb/devices/"
                                      devicerootdirs=`ls -1 $usbpath`
                                      for devicedir in $devicerootdirs; do
                                        if [ -f "$usbpath$devicedir/product" ]; then
                                          product=`cat "$usbpath$devicedir/product"`
                                          productid=`cat "$usbpath$devicedir/idProduct"`
                                          vendorid=`cat "$usbpath$devicedir/idVendor"`
                                          if [ "$removevendorid" == "$vendorid" ] && [ "$removeproductid" == "$productid" ];    then
                                            if [ -f "$usbpath$devicedir/remove" ]; then
                                              logger -p info "$0 removing $product ($vendorid:$productid)"
                                              echo 1 > "$usbpath$devicedir/remove"
                                              exit 0
                                            else
                                              logger -p info "$0 already removed $product ($vendorid:$productid)"
                                              exit 0
                                            fi
                                          fi
                                        fi
                                      done
                                    else
                                      logger -p err "$0 needs 2 args vendorid and productid"
                                      exit 1
                                    fi
                                    '';
            };
        };
    };
}
