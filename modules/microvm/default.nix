{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
# Host side of the coding-agent microVMs, after
# https://michael.stapelberg.ch/posts/2026-02-01-coding-agent-microvm-nix/
#
# A pool of identical VMs (agent1, agent2, ...). Each one shares one host
# directory, its workspace, which is picked at start: `vm` asks for the
# current directory, and microvm-prepare-<name> checks it and points the
# VM's share at it (see below).
#
# Each VM shares the host's /nix/store read-only and uses the host's
# nix-daemon (over vsock, as the untrusted user microvm-nix), so whatever it
# builds or fetches lands in the host store. It can talk to the internet but
# not to the LAN, the tailnet or the host itself. Note that builds requested
# from a VM run on the host: fixed-output (download) steps use the host's
# network, not the VM's.
let
  cfg = config.lfa.microvm;
  user = config.users.users.lucasfa;
  inherit (config.microvm) stateDir;

  bridge = "microbr";
  subnet = "192.168.83";
  hostAddress = "${subnet}.1";

  # Secrets for the VMs, shared read-only into all of them. Kept apart from
  # /run/agenix so no other host secret is reachable through the share.
  secretsDir = "/run/microvm-secrets";

  # Where `vm` asks for a VM's workspace (<name>.request, written by the
  # user). Not shared into any VM, so a VM can't pick its next workspace.
  runDir = "/run/lfa-microvm";

  # claude's state (history, settings, trust), shared by every VM. claude
  # keys it by project path, so each workspace keeps its own history
  # whichever VM runs it.
  claudeDir = "${user.home}/vms/claude";

  # Guest connections to vsock CID 2 (the host) on this port reach the host
  # nix-daemon. cloud-hypervisor forwards them to <vsock socket>_<port>.
  nixDaemonVsockPort = 5000;
  nixDaemonUser = "microvm-nix";

  # Seed for ~/.claude/.claude.json: skip onboarding and trust everything
  # under the home directory (trust is inherited by subdirs), as any of it
  # can be a workspace.
  claudeState = {
    hasCompletedOnboarding = true;
    projects.${user.home}.hasTrustDialogAccepted = true;
  };

  # Seed for ~/.claude/settings.json (user settings, so /model and /effort
  # can still change them; managed-settings would pin them instead).
  claudeSettings = {
    model = "opus";
    effortLevel = "high";
  };

  claudeStateFile = pkgs.writeText "claude.json" (builtins.toJSON claudeState);
  claudeSettingsFile = pkgs.writeText "claude-settings.json" (builtins.toJSON claudeSettings);

  # Destinations a VM may not reach: everything that isn't the public internet.
  blockedNets = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "100.64.0.0/10" # CGNAT, which is also the tailnet
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16" # includes the host's address on the bridge
    "224.0.0.0/4"
    "240.0.0.0/4"
  ];

  # The host blocks private addresses, so the LAN resolver is unreachable.
  nameservers = [
    "9.9.9.9"
    "1.1.1.1"
  ];

  mkVm = index: rec {
    name = "agent${toString index}";
    inherit (cfg) vcpu mem;
    ip = "${subnet}.${toString (10 + index)}";
    mac = "02:00:00:00:53:${lib.fixedWidthString 2 "0" (lib.toHexString index)}";
    tap = "vm-${name}";
    # vsock CIDs 0-2 are reserved.
    cid = 2 + index;
    # Infrastructure state, root-only on the host.
    sshHostKeyDir = "${stateDir}/${name}/ssh-host-keys";
    # microvm.nix's cloud-hypervisor runner uses notify.vsock in the state dir.
    nixDaemonSocket = "${stateDir}/${name}/notify.vsock_${toString nixDaemonVsockPort}";
    # Read at boot by the shared guest, see ./guest.nix. The workspace isn't
    # here: it changes between starts, and this is fixed in the runner.
    vmKernelParams = [
      "systemd.hostname=${name}"
      "ifname=uplink:${mac}"
      "ip=${ip}::${hostAddress}:255.255.255.0::uplink:off"
    ]
    ++ map (ns: "nameserver=${ns}") nameservers;
  };
  vms = lib.listToAttrs (
    map (vm: lib.nameValuePair vm.name vm) (map mkVm (lib.range 1 cfg.instances))
  );

  # One guest system for every VM, so a VM adds no NixOS evaluation (about
  # 10s and 1GB each otherwise) and they share one toplevel and initrd.
  # Evaluated like microvm.nix does for microvm.vms.<name>.config.
  guest = import "${pkgs.path}/nixos/lib/eval-config.nix" {
    inherit pkgs;
    inherit (pkgs.stdenv.hostPlatform) system;
    modules = [
      inputs.microvm.nixosModules.microvm
      ./guest.nix
    ];
    specialArgs = {
      inherit inputs self;
      shared = {
        inherit secretsDir nixDaemonVsockPort;
        inherit (cfg) extraDirs;
      };
    };
  };

  # A VM's runner: the shared guest, with this VM's devices and kernel command
  # line. Overrides every microvm option that differs between VMs or whose
  # default derives from the guest's (empty) hostname.
  mkRunner =
    vm:
    inputs.microvm.lib.buildRunner {
      inherit pkgs;
      inherit (guest.config.system.build) toplevel;
      microvmConfig = guest.config.microvm // {
        hostName = vm.name;
        machineId = null; # derived from hostName by buildRunner then
        socket = "${vm.name}.sock";
        inherit (vm) vcpu mem;
        interfaces = map (
          iface:
          iface
          // {
            id = vm.tap;
            inherit (vm) mac;
          }
        ) guest.config.microvm.interfaces;
        vsock = guest.config.microvm.vsock // {
          inherit (vm) cid;
        };
        kernelParams = guest.config.microvm.kernelParams ++ vm.vmKernelParams;
        # tap-up would create the guest's placeholder tap; the taps are networkd
        # netdevs instead (see below).
        binScripts = removeAttrs guest.config.microvm.binScripts [
          "tap-up"
          "tap-down"
        ];
      };
    };

  # Pinned by ssh for every VM, see the ssh host key service below.
  knownHostsFile = name: "${stateDir}/${name}/known_hosts";

  # `vm`: start a free VM with the current directory as its workspace (or
  # reuse the one that has it) and run claude in it. No sudo, see the polkit
  # rule.
  vmCommand = pkgs.writeShellApplication {
    name = "vm";
    runtimeInputs = [
      config.systemd.package
      config.programs.ssh.package
      pkgs.coreutils # realpath
      pkgs.util-linux # flock
    ];
    text = ''
      names=(${lib.escapeShellArgs (lib.attrNames vms)})
      extraDirs=${toString cfg.extraDirs}
      home=${lib.escapeShellArg user.home}
      runDir=${lib.escapeShellArg runDir}
      stateDir=${lib.escapeShellArg stateDir}
    ''
    + builtins.readFile ./vm.sh;
  };

  # `claude` on the host runs in a VM, like `vm -- ARGS`, wherever `vm`
  # accepts the directory (the home directory itself, which gets a stateless
  # VM without a workspace, or anywhere under it). Elsewhere, and
  # as `claude-host`, it is the host's own claude, sandboxed and with
  # permission prompts (see ../roles/desktop/claude.nix).
  hostClaude = lib.getExe pkgs.claude-code;
  claudeInVm = pkgs.writeShellApplication {
    name = "claude";
    runtimeInputs = [ vmCommand ];
    text = ''
      cwd=$(pwd -P)
      if [[ $cwd == ${lib.escapeShellArg user.home} || $cwd == ${lib.escapeShellArg user.home}/* ]]; then
        exec vm -- "$@"
      fi
      if [ -t 2 ]; then
        echo "claude: not under ${user.home}, so not in a VM; running on the host" >&2
      fi
      exec ${hostClaude} "$@"
    '';
  };
  claudeHost = pkgs.writeShellScriptBin "claude-host" ''
    exec ${hostClaude} "$@"
  '';
in
{
  options.lfa.microvm = {
    enable = lib.mkEnableOption "coding-agent microVMs";
    instances = lib.mkOption {
      type = lib.types.ints.between 1 200;
      default = 4;
      description = ''
        Number of agent VMs (agent1, agent2, ...), and so of workspaces that
        can run at once. Run `vm` in a directory to start one with it.
      '';
    };
    extraDirs = lib.mkOption {
      type = lib.types.ints.between 0 16;
      default = 3;
      description = ''
        How many directories `vm --with DIR` can share into a VM besides its
        workspace. Each is a virtiofs share (and a virtiofsd per running VM)
        whether used or not.
      '';
    };
    vcpu = lib.mkOption {
      type = lib.types.ints.positive;
      default = 6;
    };
    mem = lib.mkOption {
      type = lib.types.ints.positive;
      # A ceiling, not a reservation: with ballooning (see ./guest.nix) the
      # guest hands freed memory back to the host. Builds run on the host,
      # but evaluation runs in the VM and can take a few GiB.
      default = 6144;
      description = "Maximum RAM per VM, in MiB.";
    };
  };

  config = lib.mkMerge [
    { microvm.host.enable = cfg.enable; }
    (lib.mkIf cfg.enable {
      # Long-lived token from `claude setup-token`, used by every VM instead of
      # a per-VM login. Revocable independently of the host's own session.
      age.secrets.claude-oauth-token = {
        file = self.outPath + "/secrets/claude-oauth-token.age";
        path = "${secretsDir}/claude-oauth-token";
        symlink = false;
        owner = user.name;
        mode = "0400";
      };

      # Every VM runs cloud-hypervisor with a vsock CID (see ./guest.nix), which
      # reports readiness: `systemctl start microvm@<name>` then returns only
      # once the guest has booted.
      microvm.host.useNotifySockets = true;

      microvm.vms = lib.mapAttrs (_: vm: {
        autostart = false;
        # Just what microvm.nix's host module reads from a VM's config.
        evaluatedConfig.config = {
          microvm = {
            declaredRunner = mkRunner vm;
            # Only used for tmpfiles rules creating the share sources; ours
            # below and microvm-prepare-<name> create them instead.
            shares = [ ];
          };
          system.build.toplevel = guest.config.system.build.toplevel;
        };
      }) vms;

      ################## networking ##################
      systemd.network = {
        netdevs = {
          "20-${bridge}".netdevConfig = {
            Kind = "bridge";
            Name = bridge;
          };
        }
        # A persistent tap per VM, for cloud-hypervisor (which runs as microvm).
        // lib.mapAttrs' (
          _: vm:
          lib.nameValuePair "21-${vm.tap}" {
            netdevConfig = {
              Kind = "tap";
              Name = vm.tap;
            };
            tapConfig = {
              User = "microvm";
              Group = "kvm";
              VNetHeader = true;
              # cloud-hypervisor opens it multi-queue with more than one vCPU.
              MultiQueue = vm.vcpu > 1;
            };
          }
        ) vms;
        networks."20-${bridge}" = {
          matchConfig.Name = bridge;
          addresses = [ { Address = "${hostAddress}/24"; } ];
          networkConfig = {
            ConfigureWithoutCarrier = true;
            LinkLocalAddressing = "no";
          };
          linkConfig.RequiredForOnline = "no";
        };
        networks."21-microvm-tap" = {
          matchConfig.Name = "vm-*";
          networkConfig.Bridge = bridge;
          linkConfig.RequiredForOnline = "no";
        };
      };
      networking.networkmanager.unmanaged = [
        "interface-name:${bridge}"
        "interface-name:vm-*"
      ];

      # No externalInterface: the laptop roams between wifi and ethernet.
      networking.nat = {
        enable = true;
        internalInterfaces = [ bridge ];
      };

      # Filter in mangle/PREROUTING: it runs before both INPUT (the host itself)
      # and FORWARD, where tailscale's ts-forward chain would otherwise accept
      # VM traffic towards the tailnet before nixos-filter-forward sees it.
      networking.firewall.extraCommands = ''
        iptables -w -t mangle -N microvm-egress 2>/dev/null || iptables -w -t mangle -F microvm-egress
        # Replies to connections the host opened (e.g. ssh into the VM).
        iptables -w -t mangle -A microvm-egress -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
        # The host itself, on any address (e.g. a public one on some networks).
        iptables -w -t mangle -A microvm-egress -m addrtype --dst-type LOCAL -j DROP
        ${lib.concatMapStrings (net: ''
          iptables -w -t mangle -A microvm-egress -d ${net} -j DROP
        '') blockedNets}
        iptables -w -t mangle -C PREROUTING -i ${bridge} -j microvm-egress 2>/dev/null \
          || iptables -w -t mangle -I PREROUTING -i ${bridge} -j microvm-egress
        # The VMs are IPv4-only; this also stops them reaching the host via link-local.
        ip6tables -w -t mangle -C PREROUTING -i ${bridge} -j DROP 2>/dev/null \
          || ip6tables -w -t mangle -I PREROUTING -i ${bridge} -j DROP

        # networking.nat turns on forwarding for all interfaces, and the
        # iptables firewall can't filter it (filterForward needs nftables).
        # Forward only VM traffic, so others on the network can't use the
        # laptop as a router. Anything else that forwards (docker, tailscale
        # subnet routing) would need an exception here.
        iptables -w -t mangle -N microvm-forward 2>/dev/null || iptables -w -t mangle -F microvm-forward
        iptables -w -t mangle -A microvm-forward -i ${bridge} -j RETURN
        iptables -w -t mangle -A microvm-forward -o ${bridge} -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
        iptables -w -t mangle -A microvm-forward -j DROP
        iptables -w -t mangle -C FORWARD -j microvm-forward 2>/dev/null \
          || iptables -w -t mangle -I FORWARD -j microvm-forward
      '';
      networking.firewall.extraStopCommands = ''
        iptables -w -t mangle -D PREROUTING -i ${bridge} -j microvm-egress 2>/dev/null || true
        iptables -w -t mangle -F microvm-egress 2>/dev/null || true
        iptables -w -t mangle -X microvm-egress 2>/dev/null || true
        iptables -w -t mangle -D FORWARD -j microvm-forward 2>/dev/null || true
        iptables -w -t mangle -F microvm-forward 2>/dev/null || true
        iptables -w -t mangle -X microvm-forward 2>/dev/null || true
        ip6tables -w -t mangle -D PREROUTING -i ${bridge} -j DROP 2>/dev/null || true
      '';

      networking.hosts = lib.mapAttrs' (name: vm: lib.nameValuePair vm.ip [ name ]) vms;

      # Trust only the pinned key: no first-connection prompt, and stale
      # entries in ~/.ssh/known_hosts can't get in the way.
      programs.ssh.extraConfig = lib.concatStrings (
        lib.mapAttrsToList (name: vm: ''
          Host ${name} ${vm.ip}
            UserKnownHostsFile ${knownHostsFile name}
            StrictHostKeyChecking yes
        '') vms
      );

      environment.systemPackages = [
        vmCommand
        # Wins over pkgs.claude-code's bin/claude.
        (lib.hiPrio claudeInVm)
        claudeHost
      ];

      # Lets `vm` start and stop the VMs without sudo.
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          var units = ${builtins.toJSON (lib.mapAttrsToList (name: _: "microvm@${name}.service") vms)};
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.user == "${user.name}" &&
              units.indexOf(action.lookup("unit")) >= 0 &&
              ["start", "stop", "restart"].indexOf(action.lookup("verb")) >= 0) {
            return polkit.Result.YES;
          }
        });
      '';

      ################## per-VM state ##################
      # Sorts before microvm.nix's own "10-microvm" rules for the same paths,
      # so these owners and modes win.
      systemd.tmpfiles.settings."09-lfa-microvm" = lib.mkMerge (
        [
          {
            "${user.home}/vms".d = {
              user = user.name;
              inherit (user) group;
              mode = "0755";
            };
            "${claudeDir}".d = {
              user = user.name;
              inherit (user) group;
              mode = "0700";
            };
            # Only written if missing; claude owns the files afterwards.
            "${claudeDir}/.claude.json".f = {
              user = user.name;
              inherit (user) group;
              mode = "0600";
              argument = builtins.toJSON claudeState;
            };
            "${claudeDir}/settings.json".f = {
              user = user.name;
              inherit (user) group;
              mode = "0600";
              argument = builtins.toJSON claudeSettings;
            };
            "${secretsDir}".d = {
              user = "root";
              group = "root";
              mode = "0755";
            };
            # Root's, so the user can only write the files created for them.
            "${runDir}".d = {
              user = "root";
              group = "root";
              mode = "0755";
            };
            "${runDir}/lock".f = {
              user = user.name;
              inherit (user) group;
              mode = "0600";
            };
          }
        ]
        ++ lib.mapAttrsToList (_: vm: {
          "${runDir}/${vm.name}.request".f = {
            user = user.name;
            inherit (user) group;
            mode = "0600";
          };
          "${vm.sshHostKeyDir}".d = {
            user = "root";
            group = "root";
            mode = "0700";
          };
          # Target of the guest's relative "claude/" share source (see
          # ./guest.nix). "workspace" is linked by microvm-prepare-<name>.
          "${stateDir}/${vm.name}/claude"."L+".argument = claudeDir;
        }) vms
      );

      systemd.services = lib.mkMerge [
        # Runs as root on every start, before virtiofsd (also root) opens the
        # shares. Points the VM's workspace share (and extra<i> ones) at the
        # directories `vm` asked for, once it has checked them, and tells the
        # guest where to mount them. The request's first line is the
        # workspace (or "ephemeral"), each further one "rw PATH" or "ro PATH"
        # for `vm --with` / `--with-ro`.
        # Also keeps the stable SSH host key, generated once on the host and
        # shared read-only, and rewrites the known_hosts entry ssh pins.
        (lib.mapAttrs' (
          name: vm:
          lib.nameValuePair "microvm-prepare-${name}" {
            description = "Prepare MicroVM '${name}'";
            requiredBy = [ "microvm@${name}.service" ];
            before = [
              "microvm-virtiofsd@${name}.service"
              "microvm@${name}.service"
            ];
            serviceConfig.Type = "oneshot";
            script = ''
              mapfile -t lines < ${runDir}/${name}.request
              request=''${lines[0]-}
              # Sets dir to the checked, resolved path $1. Resolves symlinks,
              # so the checks are on what virtiofsd will actually share.
              resolve() {
                case $1 in
                  /*) ;;
                  *)
                    echo "not an absolute path: $1" >&2
                    exit 1
                    ;;
                esac
                if ! dir=$(realpath -e -- "$1") || [ ! -d "$dir" ]; then
                  echo "not a directory: $1" >&2
                  exit 1
                fi
                case $dir in
                  *$'\n'*)
                    echo "path contains a newline: $1" >&2
                    exit 1
                    ;;
                  ${lib.escapeShellArg user.home}/*) ;;
                  *)
                    echo "not under ${user.home}: $dir" >&2
                    exit 1
                    ;;
                esac
              }
              # Relative share sources in ./guest.nix resolve here.
              cd ${stateDir}/${name}
              install -d -m 0755 meta empty
              if [ -z "$request" ]; then
                echo "no workspace requested; start ${name} with \`vm\`" >&2
                exit 1
              elif [ "$request" = ephemeral ]; then
                # No host directory at all: the workspace share is an empty
                # directory (the guest skips mounting it, as meta/workspace
                # is empty) and claude's state is a fresh copy of the seeds,
                # thrown away on the next start.
                ln -sfnT -- empty workspace
                : > meta/workspace
                rm -rf -- claude-ephemeral
                install -d -o ${user.name} -g ${user.group} -m 0700 claude-ephemeral
                install -o ${user.name} -g ${user.group} -m 0600 ${claudeStateFile} claude-ephemeral/.claude.json
                install -o ${user.name} -g ${user.group} -m 0600 ${claudeSettingsFile} claude-ephemeral/settings.json
                ln -sfnT -- claude-ephemeral claude
                echo "workspace: none (ephemeral)"
              else
                resolve "$request"
                ln -sfnT -- "$dir" workspace
                printf '%s\n' "$dir" > meta/workspace
                ln -sfnT -- ${lib.escapeShellArg claudeDir} claude
                echo "workspace: $dir"
              fi

              # Line i of meta/extras is share extra<i>, which the guest
              # mounts at that path; unused shares point at the empty dir.
              : > meta/extras
              i=0
              for line in "''${lines[@]:1}"; do
                [ -n "$line" ] || continue
                i=$((i + 1))
                if [ "$i" -gt ${toString cfg.extraDirs} ]; then
                  echo "more than ${toString cfg.extraDirs} extra directories requested" >&2
                  exit 1
                fi
                mode=''${line%% *}
                case $mode in
                  rw | ro) ;;
                  *)
                    echo "not \"rw PATH\" or \"ro PATH\": $line" >&2
                    exit 1
                    ;;
                esac
                resolve "''${line#* }"
                ln -sfnT -- "$dir" "extra$i"
                printf '%s %s\n' "$mode" "$dir" >> meta/extras
                echo "extra ($mode): $dir"
              done
              for ((j = i + 1; j <= ${toString cfg.extraDirs}; j++)); do
                ln -sfnT -- empty "extra$j"
              done

              key=${vm.sshHostKeyDir}/ssh_host_ed25519_key
              if [ ! -e "$key" ]; then
                install -d -m 0700 ${vm.sshHostKeyDir}
                ${lib.getExe' pkgs.openssh "ssh-keygen"} -q -t ed25519 -N "" -C ${name} -f "$key"
              fi
              read -r type pub _ < "$key.pub"
              echo "${name},${vm.ip} $type $pub" > ${knownHostsFile name}
            '';
          }
        ) vms)

        # Relays the VM's vsock connections to the host nix-daemon. The daemon
        # sees the proxy's uid, so the VM gets microvm-nix's (untrusted) rights.
        (lib.mapAttrs' (
          name: vm:
          lib.nameValuePair "microvm-nix-daemon-${name}" {
            description = "Host nix-daemon for MicroVM '${name}'";
            requires = [ "microvm-nix-daemon-${name}.socket" ];
            after = [ "microvm-nix-daemon-${name}.socket" ];
            serviceConfig = {
              ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd /nix/var/nix/daemon-socket/socket";
              User = nixDaemonUser;
              Group = nixDaemonUser;
            };
          }
        ) vms)
      ];

      systemd.sockets = lib.mapAttrs' (
        name: vm:
        lib.nameValuePair "microvm-nix-daemon-${name}" {
          description = "Host nix-daemon for MicroVM '${name}' (vsock port ${toString nixDaemonVsockPort})";
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = vm.nixDaemonSocket;
            # cloud-hypervisor connects here; microvm.nix runs it as "microvm".
            SocketUser = "microvm";
            SocketMode = "0600";
          };
        }
      ) vms;

      users.users.${nixDaemonUser} = {
        isSystemUser = true;
        group = nixDaemonUser;
        description = "Nix daemon client for the agent microVMs";
      };
      users.groups.${nixDaemonUser} = { };
      nix.settings.allowed-users = [ nixDaemonUser ];
    })
  ];
}
