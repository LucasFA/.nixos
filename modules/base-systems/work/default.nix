{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./vm.nix
  ];
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
    libreoffice-qt
    nodejs_20
    uv
    thunderbird
    evolution
    gnome-boxes
  ];
  environment.shellAliases = {
    "sf" = "npx @salesforce/cli";
  };

  programs = {
    autofirma = {
      enable = lib.mkDefault true;
      # firefoxIntegration.enable = true;  # Let Firefox use AutoFirma
    };
    # configuradorfnmt.enable = true;
  };
}
