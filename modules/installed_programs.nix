{ pkgs, ... }:

{
  imports = [
    ./base-systems/personal 
    ./base-systems/gaming
    ./base-systems/development
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ventoy-full
    dmidecode
    lshw
  ];
}
