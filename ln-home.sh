# TODO: This method has been deprecated, use diffetc, diffhome instead
echo "TODO: Delete this script"
exit

if [ -e ~/.bashrc ]; then

  echo "dotfiles exist, be carefull!"

else

  ln ./home/me/.bashrc ~/.bashrc

  mkdir -p ~/.config/yi
  ln ./home/me/.config/yi/yi.hs ~/.config/yi/yi.hs

  mkdir -p ~/.config/pgcli
  ln ./home/me/.config/pgcli/config ~/.config/pgcli/config

  ln ./home/me/.emacs ~/

  # Can't soft link .gitconfig
  ln ./home/me/.gitconfig ~/

  ln ./home/me/.inputrc ~/

  mkdir -p ~/.nixpkgs
  ln ./home/me/.nixpkgs/yi-custom.nix ~/.nixpkgs/
  ln ./home/me/.nixpkgs/yi.nix ~/.nixpkgs/
  ln ./home/me/.nixpkgs/config.nix ~/.nixpkgs/

  ln ./home/me/.nviminfo ~/

  ln ./home/me/.vimrc ~/
  ln ./home/me/.vimrc.local ~/

  mkdir -p ~/.xmonad
  ln ./home/me/.xmonad/xmonad.hs ~/.xmonad/

fi
