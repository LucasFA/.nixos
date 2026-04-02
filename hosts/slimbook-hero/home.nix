{
  ...
}:

let
  profiles = (import ../../modules/home/profiles.nix).profiles;
in
{
  imports = [ ../../modules/home ];
}
// profiles.desktop
// {
  lfa.home = profiles.desktop.lfa.home // {
    mangohud.enable = false;
  };
}
