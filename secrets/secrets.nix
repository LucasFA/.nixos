let
  lucasfaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlwh43HbNUf/b4TRlDSi1rbCH4AlaHbdKX4eAw5AomH"; # BW key pair
  users = [ lucasfaKey ];

  slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkSNFxbS5XMLVTLbCInuhO9DNVklEv22QAEcL5+4wHI"; # /etc/ssh/id_ed25519
  hp-omen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad"; # also on github.com/lucasfa.keys
  systems = [
    slimbook
    hp-omen
  ];
in
{
  # "wifiPH.age".publicKeys = systems;
 
  age.identityPaths = [
    "/home/lucasfa/.ssh/id_ed25519_lucasfa"
    "/home/lucasfa/.ssh/id_ed25519"
    "/etc/ssh/id_ed25519"
  ];
}
