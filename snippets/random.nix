
  environment.sessionVariables = {
    # Make flatpak work, see https://wiki.nixos.org/wiki/Flatpak#Usage
    # Not needed in GNOME. For the possibility of changing to another DE or a WM, keep it.
    # XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
