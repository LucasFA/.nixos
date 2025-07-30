let
  lucasfaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlwh43HbNUf/b4TRlDSi1rbCH4AlaHbdKX4eAw5AomH"; # BW key pair
  lucasfa-server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhFT4GWADUWwma3wKIxISGk5PWA2YPZsVaXwW23tyJK";
  users = [
    lucasfaKey
  ];

  # slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkSNFxbS5XMLVTLbCInuhO9DNVklEv22QAEcL5+4wHI"; # /etc/ssh/id_ed25519
  hp-omen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad"; # also on github.com/lucasfa.keys
  server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINk6Enh1qpGbOCCH71KHVDiutXYGtra9SVKbaQbY86ZL"; # /etc/ssh/ssh_host_ed25519
  systems = [
    # slimbook
    hp-omen
    server-nuc1
  ];
  backupKeys = [
    # slimbook
    server-nuc1
    lucasfaKey
  ];
in
{
  "protonVPNPrivateKeyFile.age".publicKeys = [
    server-nuc1
    lucasfa-server-nuc1
    slimbook
  ];
  "restic/env.age".publicKeys = [ backupKeys ];
  "restic/repo.age".publicKeys = [ backupKeys ];
  "restic/applicationKey.age".publicKeys = [ backupKeys ];
}
