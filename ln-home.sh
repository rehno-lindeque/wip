if [ -e ~/.bashrc ]; then

  echo "dotfiles exist, be carefull!"

else

  ln ./home/me/.bashrc ~/.bashrc

  mkdir -p ~/.config/yi
  ln ./home/me/.config/yi/yi.hs ~/.config/yi/yi.hs

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
