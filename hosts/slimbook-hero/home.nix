{
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [ ../../modules/home ];

  # Home configuration composed for desktop use
  lfa.home = {
    gnome.enable = true;
    vscode.enable = true;
    mangohud.enable = false; # Can be toggled as needed
    mpv.enable = true;
    work.enable = false;
    zed.enable = true;
  };

  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";
}
