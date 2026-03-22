{ config, pkgs, ... }:
{
  programs.zed-editor = {
    # enable = true;
    extensions = [ ];
    userSettings = {
      vim_mode = true;
      ui_font_size = 16;
    };
  };
}
