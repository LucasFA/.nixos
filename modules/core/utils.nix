{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    trash-cli
    smartmontools
    cryptsetup
  ];
  services.locate.enable = true;
}
