{ ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        port = 1883;
        settings.allow_anonymous = true;
      }
    ];
  };

  # The broker is reachable only over the Tailscale interface.  Do not add
  # port 1883 to networking.firewall.allowedTCPPorts, which is LAN-wide.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 1883 ];
}
