{
  pkgs,
  lib,
  config,
  ...
}:

{
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

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.lucasfa.extraGroups = [ "libvirtd" ];

  services = {
  };
  programs = {
    autofirma = {
      enable = lib.mkDefault true;
      # firefoxIntegration.enable = true;  # Let Firefox use AutoFirma
    };
    # configuradorfnmt.enable = true;
  };
}
