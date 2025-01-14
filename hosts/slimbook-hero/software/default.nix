{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/core
    ../../../modules/base-systems/personal
    ../../../modules/base-systems/gaming
    ../../../modules/base-systems/development
    ../../../modules/misc.nix
  ];

  networking.hostName = "slimbook";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
