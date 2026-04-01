{
  # Profile definitions for home configuration
  # Each profile specifies which optional modules to enable

  profiles = {
    desktop = {
      gnome.enable = true;
      vscode.enable = true;
      mangohud.enable = true;
      mpv.enable = true;
      zed.enable = true;
    };

    server = {
      gnome.enable = false;
      vscode.enable = false;
      mangohud.enable = false;
      mpv.enable = false;
      zed.enable = false;
    };
  };
}
