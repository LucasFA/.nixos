let
  lucasfaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZD2ZY9cCffeIuV4NmskyQPWY+Wk7HSqb2/YPfdb7N2"; # BW key pair
  users = [ lucasfaKey ];

  slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp";
  hp-omen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSEUv/KiQ7b5JMCzL/muEYlSB5NB2+jb4mG1pDrikad"; # also on github.com/lucasfa.keys
  systems = [
    slimbook
    hp-omen
  ];
in
{
  "wifiPH.age".publicKeys = systems;
}
