{
  inputs,
  lib,
  system,
  ...
}:
{
  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.my-nur-packages.legacyPackages."${system}".overlays.qc71_slimbook_laptop
  ];
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
      "hplip"
      "obsidian"
      "n8n"
      "sftpgo"
    ];
}
