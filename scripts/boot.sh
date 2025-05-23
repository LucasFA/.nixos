#!/usr/bin/env bash

# See noboilerplate video, https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
set -e

# cd to your config dir
pushd ~/.nixos/

# Early return if no changes were detected (thanks @singiamtel!)
if git diff --quiet '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
nix fmt . &>/dev/null \
  || ( nix fmt . ; echo "formatting failed!" && exit 1)

# Shows your changes
git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch --flake . 2>&1 | tee nixos-switch.log || (grep --color error nixos-switch.log && exit 1)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
git commit -am "$current"

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
