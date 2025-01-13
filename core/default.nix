{
  lib,
  ...
}:
{
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager = {
      gnome.enable = true;
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:LucasFA/.nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "--print-build-logs"
    ];
    randomizedDelaySec = "15min";
  };
}
