{
  # Profile definitions for home configuration
  # Each profile specifies which optional modules to enable plus common home settings.
  # All lfa.home.*.enable options default to false, so only list what a profile turns on.

  profiles = {
    # Desktop profile: Full featured with GUI tools, editors, media players
    desktop = {
      home.username = "lucasfa";
      home.homeDirectory = "/home/lucasfa";
      lfa.home = {
        gnome.enable = true;
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
    };

    # Agent microVM profile (modules/microvm): headless, like a server
    microvm = {
      home.username = "lucasfa";
      home.homeDirectory = "/home/lucasfa";
    };
  };
}
