# See https://github.com/NixOS/nixpkgs/issues/195936
{
  config,
  pkgs,
  lib,
  ...
}:
{
environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
  pkgs.gst_all_1.gst-plugins-good
  pkgs.gst_all_1.gst-plugins-bad
  pkgs.gst_all_1.gst-plugins-ugly
  #pkgs.gst_all_1.gst-plugins-libav
];
}
