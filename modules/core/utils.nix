{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    dig
    trash-cli
    smartmontools
    cryptsetup
  ];
  services.locate.enable = true;
}
