{
  lib,
  pkgs,
  inputs,
  self,
  shared,
  ...
}:
# Guest side of the agent microVMs: one system, evaluated once and booted by
# every VM. `shared` comes from ./default.nix. What differs per VM is set
# there, in mkRunner: devices on the runner, and hostname, address and
# workspace on the kernel command line (vmKernelParams).
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

    You run inside a disposable microVM on the user's laptop. Only the
    workspace (the directory you were started in) is shared with the host
    (it is the user's real checkout, live). There are no git credentials; the user pushes from
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
    # vcpu, mem and the vsock CID (for systemd-notify readiness towards the
    # host's microvm@ unit) are set per VM, in mkRunner.
    # Free page reporting: memory the guest frees goes back to the host, so
    # `mem` is a ceiling rather than a reservation.
    balloon = true;

    # Placeholders: mkRunner sets each VM's tap and MAC.
    interfaces = [
      {
        type = "tap";
        id = "vm-template";
        mac = "02:00:00:00:53:00";
      }
    ];

    # Relative sources are in the VM's state dir on the host, where virtiofsd
    # runs; ./default.nix links them to that VM's directories. The trailing
    # slash makes virtiofsd follow the link, which it refuses as the shared
    # dir itself.
    shares =
      map
        (
          share:
          {
            proto = "virtiofs";
            # The default is derived from the hostname, which is set at boot.
            socket = "virtiofs-${share.tag}.sock";
          }
          // share
        )
        [
          {
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            # Enforced by virtiofsd on the host, so even root in the VM can't
            # remount it writable and tamper with the host's store.
            readOnly = true;
          }
          {
            tag = "workspace";
            source = "workspace/";
            # Not mounted here: the workspace goes at the same path as on the
            # host, which comes from the kernel command line
            # (systemd.mount-extra=, see vmKernelParams).
            mountPoint = "/mnt/workspace";
          }
          {
            tag = "claude";
            source = "claude/";
            mountPoint = "${home}/.claude";
          }
          {
            tag = "ssh-host-keys";
            source = "ssh-host-keys";
            mountPoint = "/etc/ssh/host-keys";
            readOnly = true;
          }
          {
            tag = "host-secrets";
            source = shared.secretsDir;
            mountPoint = hostSecrets;
            readOnly = true;
          }
        ];
    # No volumes: the VM is stateless; everything that persists is a share.
  };
  fileSystems."/mnt/workspace".options = [ "noauto" ];

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
      ExecStart = "${lib.getExe pkgs.socat} STDIO VSOCK-CONNECT:2:${toString shared.nixDaemonVsockPort}";
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
  # Both from the kernel command line: the hostname via systemd.hostname=, and
  # the address, gateway and DNS via systemd-network-generator's ifname=, ip=
  # and nameserver=. An empty hostName also keeps the initrd the same for
  # every VM.
  networking.hostName = "";
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.enableIPv6 = false;
  services.resolved.enable = true;
  # NixOS only enables it in a systemd initrd.
  systemd.additionalUpstreamSystemUnits = [ "systemd-network-generator.service" ];
  systemd.services.systemd-network-generator.wantedBy = [ "sysinit.target" ];

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
      set -l ws (string match -rg '\blfa\.workspace=(\S+)' < /proc/cmdline)
      and cd $ws
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
