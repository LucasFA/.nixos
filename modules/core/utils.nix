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
    bc
  ];
  services.locate.enable = true;
}
