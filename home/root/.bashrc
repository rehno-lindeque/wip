export NIX_PATH=$NIX_PATH:unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs:devpkgs=/home/me/projects/config/nixpkgs


# Use VIM mode for bash (TODO: is there a nicer way of doing this in NixOS)
# TODO: Any way to have a visual indication of normal mode / insert mode
# TODO: OTOH, perhaps switch to zsh
set -o vi

# # preserve $PWD in new gnome-terminal tab 
# if [ -e /etc/profile.d/vte.sh ]; then
#   . /etc/profile.d/vte.sh
# fi
