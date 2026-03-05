{
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhsWithPackages (
      ps: with ps; [
        octave
        ghostscript
      ]
    );
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
  };
}
