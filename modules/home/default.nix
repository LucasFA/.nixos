{
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./audio.nix
    ./devtools.nix
    ./git.nix
    ./shell.nix
    ./xdg-user.nix
    ./gnome.nix
    ./mangohud/default.nix
    ./mpv/default.nix
    ./vscode/default.nix
    ./work.nix
    ./zed.nix
  ];

  options.lfa.home = {
    gnome.enable = lib.mkEnableOption "GNOME desktop environment support";
    vscode.enable = lib.mkEnableOption "VS Code editor";
    mangohud.enable = lib.mkEnableOption "MangoHUD GPU overlay";
    mpv.enable = lib.mkEnableOption "MPV media player";
    work.enable = lib.mkEnableOption "Work-related tools";
    zed.enable = lib.mkEnableOption "Zed editor";
  };

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = false;

    home.stateVersion = "24.05";

    home.packages = with pkgs; [
      # system utilities
      htop
      fastfetch
      file
      which
      # user utilities
      ripgrep
      speedtest-cli
      zip
      unzip
      vifm
      # management
      gh
      chezmoi
    ];

    # XDG Base Directory specification environment variables
    home.sessionVariables = rec {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      # Not officially in the spec but useful
      XDG_BIN_HOME = "$HOME/.local/bin";
    };

    # Shell aliases
    home.shellAliases = {
      nvidia-settings = "nvidia-settings --config=\"$XDG_CONFIG_HOME\"/nvidia/settings";
    };
  };
}
