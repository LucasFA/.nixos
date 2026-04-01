{
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [ ../../modules/home ];

  # Minimal home configuration for server use
  lfa.home = {
    gnome.enable = false;
    vscode.enable = false;
    mangohud.enable = false;
    mpv.enable = false;
  };

  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";
}
