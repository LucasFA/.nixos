{
  self,
  config,
  ...
}:
{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  age.secrets.wirelessconf.file = self.outPath + "/secrets/wireless.conf.age";
  networking.wireless.secretsFile = "/run/agenix/wireless.conf";
  networking.wireless.networks = {
  };

}
