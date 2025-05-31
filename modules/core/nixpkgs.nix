{ lib, ... }:
{
  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "nvidia-x11"
      "nvidia-settings"
      "spotify"
      "discord"
      "unrar"
    ];
}
