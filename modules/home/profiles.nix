{
  # Profile definitions for home configuration
  # Each profile specifies which optional modules to enable plus common home settings

  profiles = {
    # Desktop profile: Full featured with GUI tools, editors, media players
    desktop = {
      home.username = "lucasfa";
      home.homeDirectory = "/home/lucasfa";
      lfa.home = {
        gnome.enable = true;
        vscode.enable = true;
        mangohud.enable = true;
        mpv.enable = true;
        opencode.enable = true;
        zed.enable = true;
      };
    };

    # Server profile: Minimal, no GUI applications
    server = {
      home.username = "lucasfa";
      home.homeDirectory = "/home/lucasfa";
      lfa.home = {
        gnome.enable = false;
        vscode.enable = false;
        mangohud.enable = false;
        mpv.enable = false;
        opencode.enable = false;
        zed.enable = false;
      };
    };
  };
}
