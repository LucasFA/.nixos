let
  lucasfaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlwh43HbNUf/b4TRlDSi1rbCH4AlaHbdKX4eAw5AomH"; # BW key pair
  lucasfa-slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp";
  lucasfa-server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhFT4GWADUWwma3wKIxISGk5PWA2YPZsVaXwW23tyJK";

  hp-omen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad"; # also on github.com/lucasfa.keys
  server-nuc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINk6Enh1qpGbOCCH71KHVDiutXYGtra9SVKbaQbY86ZL"; # /etc/ssh/ssh_host_ed25519

  backupKeys = [
    # slimbook
    server-nuc1
    lucasfaKey
  ];
  allUsers = [
    lucasfaKey
    lucasfa-slimbook
    lucasfa-server-nuc1
  ];
  workstations = [
    lucasfaKey
    lucasfa-slimbook
  ];
  servers = [
    lucasfaKey
    lucasfa-server-nuc1
  ];
in
{
  "protonVPNPrivateKeyFile.age".publicKeys = [
    server-nuc1
    lucasfa-server-nuc1
    # slimbook
  ];

  "restic/htpasswd.age".publicKeys = servers;

  "restic/passwordFile.age".publicKeys = allUsers;
  "restic/environmentFile.age".publicKeys = allUsers;
  "restic/repo.age".publicKeys = servers;
  "restic/applicationKey.age".publicKeys = servers;

}
