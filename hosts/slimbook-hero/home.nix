{ hostRole, ... }:

let
  profiles = (import ../../modules/home/profiles.nix).profiles;
in
{
  imports = [ ../../modules/home ];
}
// profiles.${hostRole}
// {
  lfa.home = profiles.${hostRole}.lfa.home // {
    mangohud.enable = false;
  };
}
