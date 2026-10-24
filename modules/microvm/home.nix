{ hostRole, ... }:

let
  profiles = (import ../home/profiles.nix).profiles;
in
{
  imports = [ ../home ];
}
// profiles.${hostRole}
