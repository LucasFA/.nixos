{
  ...
}:
{
  # https://hub.docker.com/r/adguard/adguardhome#resolved-daemon
  services.resolved.extraConfig = "[Resolve]
DNS=127.0.0.1
DNSStubListener=no
";
  services.adguardhome = {
    enable = false;
  };
}
