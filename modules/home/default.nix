{
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./devtools.nix
    ./git.nix
    ./gnome
    ./mangohud/default.nix
    ./mpv/default.nix
    ./vscode.nix
    ./zed.nix
  ];

  options.lfa.home = {
    gnome.enable = lib.mkEnableOption "GNOME desktop environment support";
    vscode.enable = lib.mkEnableOption "VS Code editor";
    mangohud.enable = lib.mkEnableOption "MangoHUD GPU overlay";
    mpv.enable = lib.mkEnableOption "MPV media player";
    zed.enable = lib.mkEnableOption "Zed editor";
  };

  config = {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = false;

    home.stateVersion = "24.05";

    # Programs
    programs = {
      bash.enable = true;
      fish.enable = true;
    };

    # XDG user directories
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;
    xdg.userDirs.music = "${config.home.homeDirectory}/xdg/Music";
    xdg.userDirs.desktop = "${config.home.homeDirectory}/xdg/Desktop";
    xdg.userDirs.pictures = "${config.home.homeDirectory}/xdg/Pictures";
    xdg.userDirs.publicShare = "${config.home.homeDirectory}/xdg/Public";
    xdg.userDirs.templates = "${config.home.homeDirectory}/xdg/Templates";
    xdg.userDirs.videos = "${config.home.homeDirectory}/xdg/Videos";

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
    home.sessionVariables = {
      EDITOR = "vim";
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
