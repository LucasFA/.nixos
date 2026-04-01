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
    mangohud.enable = true;
    mpv.enable = true;
    zed.enable = true;
  };

  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";
}
