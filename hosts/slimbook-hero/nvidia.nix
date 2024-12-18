{ pkgs, config, libs, ... }:

{

  hardware.graphics = {
	enable = true;
	enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["nvidia"]; #implied by nixos-hardware

  hardware.nvidia = {
    # modesetting.enable = true; # set by nixos-hardware. Required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 

    # open = true; # implied by nixos-hardware

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

}
