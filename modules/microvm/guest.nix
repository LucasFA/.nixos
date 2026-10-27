{
  lib,
  pkgs,
  inputs,
  self,
  vm,
  ...
}:
# Guest side of an agent microVM. `vm` comes from ./default.nix (mkVm).
let
  home = "/home/lucasfa";
  hostSecrets = "/run/host-secrets";

  # Log in with the shared token from the host instead of per-VM OAuth.
  # Passed as a file descriptor rather than CLAUDE_CODE_OAUTH_TOKEN, so the
  # token isn't in the environment of the commands claude runs (where an
  # `env` dump could leak it). Not CLAUDE_CODE_SUBPROCESS_ENV_SCRUB: that
  # forces the permission mode to default, overriding bypassPermissions below.
  claude = pkgs.writeShellScriptBin "claude" ''
    if [ -r ${hostSecrets}/claude-oauth-token ]; then
      exec 3<${hostSecrets}/claude-oauth-token
      export CLAUDE_CODE_OAUTH_TOKEN_FILE_DESCRIPTOR=3
    fi
    exec ${lib.getExe pkgs.claude-code} "$@"
  '';

  claudeMd = ''
    # This machine: an isolated NixOS microVM

    You run inside a disposable microVM on the user's laptop. Only
    `${vm.workspace}` is shared with the host (it is the user's real
    checkout, live). There are no git credentials; the user pushes from
    the host. You have internet access, but no access to the LAN, the
    tailnet or the host. There is no sudo.

    `pip install`, `npm install -g`, `apt` and similar installers do not
    work. Get tools from nixpkgs instead. Nix here is a client of the
    host's Nix daemon, so everything lands in the host's store and persists:

    - One-off: `nix run nixpkgs#<attr> -- <args>`
    - Several: `nix shell nixpkgs#<attr> nixpkgs#<attr> -c <command>`
    - Python modules:
      `nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages (ps: [ ps.<module> ])' -c python3`
    - Projects with a `flake.nix`: `nix develop -c <command>`

    `nixpkgs` is pinned to the host's nixpkgs. Attribute names can differ
    from command names (`pdftotext` is in `poppler-utils`).

    Don't run `nix-collect-garbage` / `nix store gc`: it is the host's
    store, and the host collects garbage on its own schedule.
  '';
in
{
  imports = [
    ../core/base.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  system.stateVersion = "26.05";

  microvm = {
    hypervisor = "cloud-hypervisor";
    inherit (vm) vcpu mem;
    # Free page reporting: memory the guest frees goes back to the host, so
    # `mem` is a ceiling rather than a reservation.
    balloon = true;
    # For systemd-notify readiness towards the host's microvm@ unit.
    vsock.cid = vm.cid;

    interfaces = [
      {
        type = "tap";
        id = "vm-${vm.name}";
        inherit (vm) mac;
      }
    ];

    shares = [
      {
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        # Enforced by virtiofsd on the host, so even root in the VM can't
        # remount it writable and tamper with the host's store.
        readOnly = true;
      }
      {
        proto = "virtiofs";
        tag = "workspace";
        source = vm.workspace;
        mountPoint = vm.workspace;
      }
      {
        proto = "virtiofs";
        tag = "claude";
        source = "${vm.dataDir}/claude";
        mountPoint = "${home}/.claude";
      }
      {
        proto = "virtiofs";
        tag = "ssh-host-keys";
        source = vm.sshHostKeyDir;
        mountPoint = "/etc/ssh/host-keys";
        readOnly = true;
      }
      {
        proto = "virtiofs";
        tag = "host-secrets";
        source = vm.secretsDir;
        mountPoint = hostSecrets;
        readOnly = true;
      }
    ];
    # No volumes: the VM is stateless; everything that persists is a share.
  };

  ################## nix: client of the host's daemon ##################
  # /nix/store is the host's (read-only share). Builds and downloads are done
  # by the host's nix-daemon, reached over vsock (see ./default.nix), so
  # results land in the host store and show up here immediately.
  systemd.services.nix-daemon.enable = false;
  systemd.sockets.nix-daemon.enable = false;
  systemd.sockets.host-nix-daemon = {
    description = "Host nix-daemon (via vsock)";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "/nix/var/nix/daemon-socket/socket";
      SocketMode = "0666";
      Accept = true;
    };
  };
  systemd.services."host-nix-daemon@" = {
    description = "Host nix-daemon connection (via vsock)";
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.socat} STDIO VSOCK-CONNECT:2:${toString vm.nixDaemonVsockPort}";
      StandardInput = "socket";
      DynamicUser = true;
    };
  };
  # Fail loudly rather than silently falling back to a local chroot store.
  nix.settings.store = "daemon";
  # There is no local store DB to register the closure in.
  microvm.registerClosure = false;

  # Same nixpkgs as the host, so `nix run nixpkgs#...` shares store paths with it
  # and needs no registry download.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  ################## networking ##################
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.enableIPv6 = false;
  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = vm.mac;
    address = [ "${vm.ip}/24" ];
    gateway = [ vm.gateway ];
    # The host blocks private addresses, so the LAN resolver is unreachable.
    dns = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    networkConfig.LinkLocalAddressing = "no";
  };
  services.resolved.enable = true;

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/host-keys/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  ################## user ##################
  users.mutableUsers = false;
  # Deliberately no root/wheel login: the agent gets no root. The VM is
  # rebuilt from the host, so there is nothing to be locked out of.
  users.allowNoPasswordLogin = true;
  # Nobody here may use it anyway; don't ship the setuid binary.
  security.sudo.enable = false;
  users.users.lucasfa = {
    isNormalUser = true;
    # Same uid/gid as on the host, so files in the shares have the right owner.
    uid = 1000;
    group = "users";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8s/0c98/d6Q6SkPTzKS0S7lm26uIywus/YNXKs3Ayp" # Slimbook lucasfa
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    # Install into /etc/profiles instead of via nix-env.
    useUserPackages = true;
    extraSpecialArgs = {
      inherit self;
      hostRole = "microvm";
    };
    users.lucasfa = ./home.nix;
  };

  # A plain `ssh <vm>` starts in the workspace (`vm` cds on its own).
  programs.fish.loginShellInit = ''
    if test "$PWD" = "$HOME"
      cd ${lib.escapeShellArg vm.workspace}
    end
  '';

  ################## tools ##################
  # Anything else: `nix shell nixpkgs#...` (see claudeMd).
  environment.systemPackages = [ claude ];

  # Keep claude's per-VM state (history, seeded .claude.json) in the persistent share.
  environment.sessionVariables.CLAUDE_CONFIG_DIR = "${home}/.claude";
  # Same for every VM. Unlike the host's (modules/roles/desktop/claude.nix):
  # the VM itself is the sandbox, so no bubblewrap and no permission prompts.
  environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
    inherit claudeMd;
    sandbox.enabled = false;
    permissions.defaultMode = "bypassPermissions";
    skipDangerousModePermissionPrompt = true;
  };
}
