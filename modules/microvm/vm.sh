# The `vm` command. ./default.nix prepends the definitions of:
#   names     the VM instances (array)
#   home      the user's home directory
#   runDir    where `vm` leaves its workspace requests and the lock
#   stateDir  the VMs' state on the host (microvm-prepare-<name> writes the
#             workspace to <name>/meta/workspace)
# shellcheck shell=bash disable=SC2154

usage() {
  cat >&2 <<EOF
usage: vm [-- CLAUDE_ARGS...]  run claude in a VM with the current directory
       vm shell                open a shell in that VM
       vm stop [NAME]          stop that VM, or NAME
       vm status
Any directory under $home can be a workspace. It is mounted at the same
path, and a running VM is reused for its workspace and the directories
below it. In $home itself the VM is ephemeral: nothing from the host is
mounted, claude starts with fresh state, and every run gets its own VM.
VMs: ${names[*]}
EOF
  exit 2
}

state() {
  systemctl is-active "microvm@$1.service" || true
}

# The workspace of a running (or booting) VM; empty if it is stopped.
workspace_of() {
  case $(state "$1") in
    active | activating | reloading) cat "$stateDir/$1/meta/workspace" 2>/dev/null || true ;;
  esac
}

# The running VM whose workspace contains $dir (the innermost, if several).
find_vm() {
  local n ws found="" best=""
  for n in "${names[@]}"; do
    ws=$(workspace_of "$n")
    # An empty ws (stopped VM) must not match: "$ws"/* would be /*.
    if [ -n "$ws" ] && [[ $dir == "$ws" || $dir == "$ws"/* ]] && [ ${#ws} -gt ${#best} ]; then
      found=$n
      best=$ws
    fi
  done
  echo "$found"
}

status() {
  local n s ws
  for n in "${names[@]}"; do
    s=$(state "$n")
    ws=$(workspace_of "$n")
    # A running VM with an empty workspace file is an ephemeral one.
    if [ -z "$ws" ] && [ "$s" = active ]; then ws="(ephemeral)"; fi
    printf '%s\t%s\t%s\n' "$n" "$s" "$ws"
  done
}

cmd=claude
case ${1-} in
  shell | stop | status)
    cmd=$1
    shift
    ;;
  --) shift ;;
  "") ;;
  *) usage ;;
esac

if [ "$cmd" = status ]; then
  [ $# -eq 0 ] || usage
  status
  exit 0
fi

# Physical path: the host service resolves symlinks too, and the VM sees the
# workspace only under its real path.
dir=$(pwd -P)

if [ "$cmd" = stop ]; then
  [ $# -le 1 ] || usage
  name=${1-$(find_vm)}
  if [ -z "$name" ]; then
    echo "vm: no running VM has $dir in its workspace" >&2
    exit 1
  fi
  exec systemctl stop "microvm@$name.service"
fi

if [ "$cmd" = shell ] && [ $# -gt 0 ]; then
  usage
fi
# The host service checks this too, but not before a VM is taken.
if [[ $dir != "$home" && $dir != "$home"/* ]]; then
  echo "vm: $dir is not under $home" >&2
  exit 1
fi
# The home directory itself is never a workspace: it gets an ephemeral VM.
ephemeral=
[ "$dir" = "$home" ] && ephemeral=1

# Picking a free VM and starting it must not interleave with another `vm`,
# or both could pick the same one. Held until the VM is up: before that its
# unit still looks stopped.
exec 9>"$runDir/lock"
flock 9

name=
[ -n "$ephemeral" ] || name=$(find_vm)
if [ -z "$name" ]; then
  for n in "${names[@]}"; do
    case $(state "$n") in
      inactive | failed)
        name=$n
        break
        ;;
    esac
  done
  if [ -z "$name" ]; then
    echo "vm: every VM is in use (\`vm stop NAME\` to free one):" >&2
    status >&2
    exit 1
  fi
  # Read by microvm-prepare-$name, which checks it and shares it.
  if [ -n "$ephemeral" ]; then
    printf '%s' ephemeral >"$runDir/$name.request"
    echo "vm: starting $name (ephemeral, nothing mounted)..." >&2
  else
    printf '%s' "$dir" >"$runDir/$name.request"
    echo "vm: starting $name for $dir..." >&2
  fi
fi

# A no-op if it is running; otherwise blocks until the guest has booted.
if ! systemctl start "microvm@$name.service"; then
  echo "vm: $name failed to start, see: journalctl -u microvm-prepare-$name -u microvm@$name" >&2
  exit 1
fi
exec 9>&-

# Runs under the guest's bash -c, so bash quoting is right. A terminal only
# when there is one, so `claude -p ... | jq` and `echo ... | claude -p` get
# clean pipes (no pty CRLFs); ssh relays the exit status either way.
tty=-T
[ -t 0 ] && [ -t 1 ] && tty=-t
if [ "$cmd" = shell ]; then
  remote="cd ${dir@Q} && exec bash -l"
else
  remote="cd ${dir@Q} && exec claude ${*@Q}"
fi
if [ -z "$ephemeral" ]; then
  exec ssh "$tty" -o ConnectionAttempts=10 "$name" "$remote"
fi
# Nothing of an ephemeral VM is kept, and nobody else can reuse it (it has no
# workspace to match), so stop it when the session ends to free its slot.
rc=0
ssh "$tty" -o ConnectionAttempts=10 "$name" "$remote" || rc=$?
systemctl stop "microvm@$name.service" || true
exit "$rc"
