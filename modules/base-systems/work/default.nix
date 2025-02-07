{
  pkgs,
  lib,
  config,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
  ];
  environment.shellAliases = {
    "sf" = "npx @salesforce/cli";
  };

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
