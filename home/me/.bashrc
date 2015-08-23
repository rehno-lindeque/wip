# .bashrc is a file that is sourced whenever a new bash terminal is opened
# this is a good place to modify your environment variables etc

# Guidelines for this tutorial: 
# * use descriptive flags (e.g. instead of fgrep -i we write fgrep --ignore-case)

# Add unstable packages to nix without running entirely off of the unstable channel 
# This allows import <unstable> {} to be used in /etc/nixos/configuration.nix
export NIX_PATH=$NIX_PATH:unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs:devpkgs=/home/rehno/projects/config/nixpkgs

# Use VIM mode for bash (TODO: is there a nicer way of doing this in NixOS)
# TODO: Any way to have a visual indication of normal mode / insert mode
# TODO: OTOH, perhaps switch to zsh
set -o vi

# # Create a [nix? alias](https://nixos.org/wiki/Howto_find_a_package_in_NixOS#Aliases)
# # E.g. search for emacs packages and browse around in less:
# # $ nixq emacs | less
# #
# # * This is defined as nix?() { ... } in the document above, but that syntax does not appear to be valid in bash
# # * You can also use nox to browse/install packages interactively
# # nixq(){ nix-env --query --available --attr-path --description | fgrep --ignore-case "$1" --color; }
# 
# # preserve $PWD in new gnome-terminal tab 
# if [ -e /etc/profile.d/vte.sh ]; then
#   . /etc/profile.d/vte.sh
# fi

