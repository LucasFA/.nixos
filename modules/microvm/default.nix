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

  # Guest connections to vsock CID 2 (the host) on this port reach the host
  # nix-daemon. cloud-hypervisor forwards them to <vsock socket>_<port>.
  nixDaemonVsockPort = 5000;
  nixDaemonUser = "microvm-nix";

  # Seed for each VM's ~/.claude/.claude.json, so a fresh VM skips onboarding
  # and trusts everything under ~/workspace (trust is inherited by subdirs).
  claudeState = vm: {
    hasCompletedOnboarding = true;
    projects.${vm.workspace}.hasTrustDialogAccepted = true;
  };

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

  mkVm = name: vmCfg: rec {
    inherit name;
    inherit (vmCfg) vcpu mem workspace;
    ip = "${subnet}.${toString (10 + vmCfg.index)}";
    mac = "02:00:00:00:53:${lib.fixedWidthString 2 "0" (lib.toHexString vmCfg.index)}";
    tap = "vm-${name}";
    # vsock CIDs 0-2 are reserved.
    cid = 2 + vmCfg.index;
    # Per-VM claude state, owned by lucasfa on the host.
    dataDir = "${user.home}/vms/${name}";
    # Infrastructure state, root-only on the host.
    sshHostKeyDir = "${stateDir}/${name}/ssh-host-keys";
    # microvm.nix's cloud-hypervisor runner uses notify.vsock in the state dir.
    nixDaemonSocket = "${stateDir}/${name}/notify.vsock_${toString nixDaemonVsockPort}";
    # Read at boot by the shared guest, see ./guest.nix.
    vmKernelParams = [
      "systemd.hostname=${name}"
      "ifname=uplink:${mac}"
      "ip=${ip}::${hostAddress}:255.255.255.0::uplink:off"
      "systemd.mount-extra=workspace:${workspace}:virtiofs"
      "lfa.workspace=${workspace}"
    ]
    ++ map (ns: "nameserver=${ns}") nameservers;
  };
  vms = lib.mapAttrs mkVm cfg.vms;

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
      shared = { inherit secretsDir nixDaemonVsockPort; };
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

  # `vm [NAME]`: start the VM (no sudo, see the polkit rule) and run claude in
  # it, in the same directory as on the host when inside its workspace.
  vmCommand = pkgs.writeShellApplication {
    name = "vm";
    runtimeInputs = [
      config.systemd.package
      config.programs.ssh.package
    ];
    text = ''
      names=(${lib.escapeShellArgs (lib.attrNames vms)})
      declare -A workspaces=(
      ${
        lib.concatStrings (
          lib.mapAttrsToList (
            name: vm: "  [${lib.escapeShellArg name}]=${lib.escapeShellArg vm.workspace}\n"
          ) vms
        )
      })

      usage() {
        cat >&2 <<EOF
      usage: vm [NAME] [-- CLAUDE_ARGS...]  start NAME and run claude in it
             vm shell [NAME]                start NAME and open a shell in it
             vm stop [NAME]
             vm status
      NAME defaults to the VM whose workspace contains the current directory.
      VMs: ''${names[*]}
      EOF
        exit 2
      }

      in_workspace() {
        [[ $PWD == "$1" || $PWD == "$1"/* ]]
      }

      cmd=claude
      case ''${1-} in
        shell | stop | status)
          cmd=$1
          shift
          ;;
        -h | --help) usage ;;
      esac

      if [ "$cmd" = status ]; then
        for n in "''${names[@]}"; do
          printf '%s\t%s\t%s\n' "$n" "$(systemctl is-active "microvm@$n.service" || true)" "''${workspaces[$n]}"
        done
        exit 0
      fi

      name=""
      if [ $# -gt 0 ] && [ "$1" != -- ]; then
        name=$1
        shift
      fi
      if [ "''${1-}" = -- ]; then
        shift
      fi
      if [ "$cmd" != claude ] && [ $# -gt 0 ]; then
        usage
      fi

      if [ -z "$name" ]; then
        # The innermost workspace wins if they nest.
        best=""
        for n in "''${names[@]}"; do
          ws=''${workspaces[$n]}
          if in_workspace "$ws" && [ ''${#ws} -gt ''${#best} ]; then
            name=$n
            best=$ws
          fi
        done
        if [ -z "$name" ]; then
          echo "vm: $PWD is not in any VM's workspace, pass a NAME" >&2
          usage
        fi
      elif [ -z "''${workspaces[$name]+x}" ]; then
        echo "vm: unknown VM: $name" >&2
        usage
      fi

      ws=''${workspaces[$name]}
      # The workspace is mounted at the same path in the VM.
      dir=$ws
      if in_workspace "$ws"; then
        dir=$PWD
      fi

      unit="microvm@$name.service"
      if [ "$cmd" = stop ]; then
        exec systemctl stop "$unit"
      fi
      # A no-op if it is running; otherwise blocks until the guest has booted.
      if ! systemctl is-active -q "$unit"; then
        echo "vm: starting $name..." >&2
      fi
      systemctl start "$unit"

      # Runs under the guest's bash -c, so bash quoting is right.
      if [ "$cmd" = shell ]; then
        remote="cd ''${dir@Q} && exec bash -l"
      else
        remote="cd ''${dir@Q} && exec claude ''${*@Q}"
      fi
      exec ssh -t -o ConnectionAttempts=10 "$name" "$remote"
    '';
  };
in
{
  options.lfa.microvm = {
    enable = lib.mkEnableOption "coding-agent microVMs";
    vms = lib.mkOption {
      default = { };
      description = "Agent microVMs. Start one and run claude in it with `vm <name>`.";
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              index = lib.mkOption {
                type = lib.types.ints.between 1 200;
                description = "Unique per VM; determines its IP (${subnet}.<10+index>) and MAC.";
              };
              workspace = lib.mkOption {
                type = lib.types.str;
                default = "${user.home}/vms/${name}/workspace";
                description = "Host directory shared read-write into the VM, at the same path.";
              };
              vcpu = lib.mkOption {
                type = lib.types.ints.positive;
                default = 6;
              };
              mem = lib.mkOption {
                type = lib.types.ints.positive;
                # A ceiling, not a reservation: with ballooning (see ./guest.nix)
                # the guest hands freed memory back to the host. Builds run on
                # the host, but evaluation runs in the VM and can take a few GiB.
                default = 6144;
                description = "Maximum RAM in MiB.";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkMerge [
    { microvm.host.enable = cfg.enable; }
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.allUnique (lib.mapAttrsToList (_: v: v.index) cfg.vms);
          message = "lfa.microvm.vms: every VM needs a unique index";
        }
        {
          assertion = lib.all (v: builtins.match "/[^[:space:]:\"']*" v.workspace != null) (
            lib.attrValues cfg.vms
          );
          message = "lfa.microvm.vms: a workspace must be an absolute path without whitespace, colons or quotes (it goes on the guest's kernel command line)";
        }
      ];

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
            # below create them instead.
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

      environment.systemPackages = [ vmCommand ];

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
            "${secretsDir}".d = {
              user = "root";
              group = "root";
              mode = "0755";
            };
          }
        ]
        ++ lib.mapAttrsToList (_: vm: {
          "${vm.dataDir}".d = {
            user = user.name;
            inherit (user) group;
            mode = "0755";
          };
          # ":" = only when creating it; an existing project dir is left alone.
          "${vm.workspace}".d = {
            user = ":${user.name}";
            group = ":${user.group}";
            mode = ":0755";
          };
          "${vm.dataDir}/claude".d = {
            user = user.name;
            inherit (user) group;
            mode = "0700";
          };
          # Only written if missing; claude owns the file afterwards.
          "${vm.dataDir}/claude/.claude.json".f = {
            user = user.name;
            inherit (user) group;
            mode = "0600";
            argument = builtins.toJSON (claudeState vm);
          };
          "${vm.sshHostKeyDir}".d = {
            user = "root";
            group = "root";
            mode = "0700";
          };
          # Targets of the guest's relative share sources (see ./guest.nix).
          "${stateDir}/${vm.name}/workspace"."L+".argument = vm.workspace;
          "${stateDir}/${vm.name}/claude"."L+".argument = "${vm.dataDir}/claude";
        }) vms
      );

      systemd.services = lib.mkMerge [
        # Stable SSH host keys, generated once on the host and shared read-only.
        # Runs on every start to (re)write the known_hosts entry ssh pins.
        (lib.mapAttrs' (
          name: vm:
          lib.nameValuePair "microvm-ssh-host-key-${name}" {
            description = "Generate SSH host key for MicroVM '${name}'";
            requiredBy = [ "microvm@${name}.service" ];
            before = [
              "microvm-virtiofsd@${name}.service"
              "microvm@${name}.service"
            ];
            serviceConfig.Type = "oneshot";
            script = ''
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
