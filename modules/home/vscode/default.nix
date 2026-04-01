{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.lfa.home.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode-fhs;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];
    };
  };
}
