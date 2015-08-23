if [ -e ~/.bashrc ]; then

  echo "dotfiles exist, be carefull!"

else

  ln -s home/me/.bashrc ~/.bashrc

  mkdir -p ~/.config/yi
  ln home/me/.config/yi/yi.hs ~/.config/yi/yi.hs

  ln -s home/me/.emacs ~/

  # Can't soft link .gitconfig
  ln home/me/.gitconfig ~/

  ln -s home/me/.inputrc ~/

  mkdir -p ~/.nixpkgs
  ln -s home/me/.nixpkgs/yi-custom.nix ~/.nixpkgs/
  ln -s home/me/.nixpkgs/yi.nix ~/.nixpkgs/
  ln -s home/me/.nixpkgs/config.nix ~/.nixpkgs/

  ln -s home/me/.nviminfo ~/

  ln home/me/.vimrc ~/
  ln home/me/.vimrc.local ~/

  mkdir -p ~/.xmonad
  ln -s home/me/.xmonad/xmonad.hs ~/.xmonad/

fi
