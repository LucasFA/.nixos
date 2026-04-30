{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
in
{
  imports = [
    ./graphical
    ./development.nix
    ./gaming.nix
    ./personal.nix
    ./laptop.nix
  ];

  options.lfa.roles.desktop.enable =
    lib.mkEnableOption "desktop role (graphical + personal + gaming + development tools)";

  config = lib.mkIf cfg.enable {
    # Core configuration that doesn't fit into feature files
    programs.nix-ld.enable = true;

    boot.kernel.sysctl = {
      "net.core.rmem_max" = 6400000;
      "net.core.wmem_max" = 6400000;
    };

    programs.htop.enable = true;

    environment.systemPackages = with pkgs; [
      fd
      bat
      jq
    ];
  };
}
