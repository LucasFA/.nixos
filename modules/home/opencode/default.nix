{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.lfa.home.opencode.enable =
    lib.mkEnableOption "opencode AI coding assistant with hardened config";

  config = lib.mkIf config.lfa.home.opencode.enable {
    xdg.configFile."opencode/opencode.jsonc".source = ./opencode.jsonc;
    xdg.configFile."opencode/plugins/ssrf-block.js".source = ./plugins/ssrf-block.js;
    xdg.configFile."opencode/plugins/env-scrub.js".source = ./plugins/env-scrub.js;
    xdg.configFile."opencode/plugins/secret-redact.js".source = ./plugins/secret-redact.js;
  };
}
