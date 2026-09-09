let
  lucasfaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlwh43HbNUf/b4TRlDSi1rbCH4AlaHbdKX4eAw5AomH"; # BW key pair
  lucasfa-slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp";
  lucasfa-server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhFT4GWADUWwma3wKIxISGk5PWA2YPZsVaXwW23tyJK";
  lucasfa-server-node804 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrXVpsAdmv5dRldNMLuJKc8l37oO/Wwo9F6MJ0XcBXA";

  hp-omen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad"; # also on github.com/lucasfa.keys
  server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINk6Enh1qpGbOCCH71KHVDiutXYGtra9SVKbaQbY86ZL"; # /etc/ssh/ssh_host_ed25519

  keys = {
    # Keep the Bitwarden key in every recipient group as the recovery key.
    bitwarden = [ lucasfaKey ];
    slimbook = [ lucasfa-slimbook ];
    serverNuc1 = [
      lucasfa-server-nuc1
      server-nuc1
    ];
    serverNode804 = [ lucasfa-server-node804 ];
  };

  recipients = {
    desktop = keys.bitwarden ++ keys.slimbook;
    restic = keys.bitwarden ++ keys.slimbook ++ keys.serverNuc1 ++ keys.serverNode804;
    gmail = keys.bitwarden ++ keys.slimbook ++ keys.serverNuc1 ++ keys.serverNode804;
    protonVPN = keys.bitwarden ++ keys.slimbook ++ keys.serverNuc1 ++ keys.serverNode804;
  };
in
{
  "gmailAddress.age".publicKeys = recipients.gmail;
  "protonVPNPrivateKeyFile.age".publicKeys = recipients.protonVPN;
  "wireless.conf.age".publicKeys = recipients.desktop;

  "restic/htpasswd.age".publicKeys = recipients.restic;
  "restic/passwordFile.age".publicKeys = recipients.restic;
  "restic/environmentFile.age".publicKeys = recipients.restic;
  "restic/backblazeCredentials.age".publicKeys = recipients.restic;

}
