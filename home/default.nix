{ config, pkgs, ... }:
{
  imports = [
    ./nixos_specific
    ./git
    ./zed
    ./shell
    ./vscode
    ./devtools
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lucasfa";
  home.homeDirectory = "/home/lucasfa";

  services.caffeine.enable = true;

  home.packages = with pkgs; [
    # system utilities
    htop
    neofetch
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

    # GUI packages
    mpv
    spotify
  ];
  programs = {
  };
  #home.packages = [
  # # It is sometimes useful to fine-tune packages, for example, by applying
  # # overrides. You can do that directly here, just don't forget the
  # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  # # fonts?
  # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

  # # You can also create simple shell scripts directly inside your
  # # configuration. For example, this adds a command 'my-hello' to your
  # # environment:
  # (pkgs.writeShellScriptBin "my-hello" ''
  #   echo "Hello, ${config.home.username}!"
  # '')
  #];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lucasfa/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = rec {
    EDITOR = "vim";

    # XDG
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    # Not officially in the spec
    XDG_BIN_HOME = "$HOME/.local/bin";

    # CARGO_HOME="$XDG_DATA_HOME"/cargo;
    # PATH="$CARGO_HOME/bin:$PATH"; # Well, I'll be installing stuff with nix rather than directly with cargo
    # RUSTUP_HOME="$XDG_DATA_HOME"/rustup;

    # WINEPREFIX="$XDG_DATA_HOME"/wine;
    # CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv;
    # DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker;
  };
  home.shellAliases = {
    nvidia-settings = "nvidia-settings --config=\"$XDG_CONFIG_HOME\"/nvidia/settings";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;

}
