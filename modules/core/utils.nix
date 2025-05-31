{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    dig
    dust
    trash-cli
    smartmontools
    cryptsetup
    bc
  ];
  services.locate.enable = true;
}
