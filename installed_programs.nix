{ config, pkgs, ... }:

{
  imports = [ ];

  services = {
	flatpak.enable = true;
	tailscale.enable = true;
  	syncthing = {
	  enable = true;
	  dataDir = "/home/lucasfa/syncthing/";
	  user = "lucasfa";
	  group = "users";
	  openDefaultPorts = true;
  	  guiAddress = "127.0.0.1:8384";
	  overrideDevices = false;
	  overrideFolders = false;
  };
};

  programs = {
	firefox.enable = true;
	bash = {
	  interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
        };
  	fish.enable = true;
  	htop.enable = true;
	steam.enable = true;
	gamemode.enable = true;
  };
  environment.shellAliases = {
	nixos-rbb = "nixos-rebuild build --flake . && nvd diff /run/current-system result";
	nixos-rbs = "nixos-rebuild switch --flake .";
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    gparted
    btrfs-progs
    ventoy-full
    tealdeer
    dconf
    wl-clipboard
    nvd
    nix-inspect
  #  wget
    dmidecode
    lshw
  ];
}
