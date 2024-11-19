# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# test

{ self, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hosts/slimbook-hero
      ./installed_programs.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
	enable = true;
        copyKernels = false; # no need: uses them straight from /nix/store
	useOSProber = true;
	efiSupport = true;
     	#efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
    	device = "nodev";
      	font = "${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf";
	fontSize = 36;
	extraEntries = ''
                menuentry "Reboot" {
                    reboot
                }
 		menuentry "Poweroff" {
                    halt
                }
		'';
  };

  boot.kernelParams = [
];
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
	enable = true; # Yeah, no. Even using Wayland I need this. Just goes to TTY not an issue

  # Enable the GNOME Desktop Environment.
  	displayManager.gdm = {
		enable = true;
		wayland = true;
	};
	desktopManager = {
  		gnome.enable = true;
	};
  	# Configure keymap in X11
  	xkb = {
    		layout = "us";
    		variant = "";
  	};
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucasfa = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    	# thunderbird
    	mpv
    	gnome.gnome-tweaks
	spotify
	docker
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    gparted
    ventoy-full
    tealdeer
    dconf
    wl-clipboard
  #  wget
  ];
  environment.gnome.excludePackages = (with pkgs; [
	gnome-photos
	gnome-tour
	gedit
]) ++ (with pkgs.gnome; [
	gnome-music
	epiphany # web browser
	totem # video player
	geary # email reader
	]);

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nixFlakes;
}
