{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.zed.enable {
    programs.zed-editor = {
      extensions = [ "latex" ];
      userSettings = {
        vim_mode = true;
        ui_font_size = 16;
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "zeditor" ''
        export MESA_VK_WSI_PRESENT_MODE=mailbox
        exec ${pkgs.zed-editor}/bin/zeditor "$@"
      '')
    ];
  };
}
