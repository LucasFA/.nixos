{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.zed.enable {
    programs.zed-editor = {
      extensions = [ ];
      userSettings = {
        vim_mode = true;
        ui_font_size = 16;
      };
    };
  };
}
