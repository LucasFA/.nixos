---
name: new-vm
description: Add a coding-agent microVM (lfa.microvm.vms.<name>) to slimbook for a given project directory, so `vm` inside that directory runs claude in an isolated VM. Use when the user asks for a microVM / agent VM / sandbox VM for a dir, repo or project.
argument-hint: <project dir> [vm name]
---

# Add an agent microVM for a project

Arguments: `$ARGUMENTS` — a project directory (absolute, `~/...`, or relative to
the user's home) and optionally a VM name. If no directory was given, ask for it.

The machinery lives in `modules/microvm/default.nix` (host) and
`modules/microvm/guest.nix` (guest). VMs are declared only on slimbook, in
`hosts/slimbook-hero/software/default.nix` under `lfa.microvm.vms`. Adding one
is a single attrset entry there; everything else (bridge IP, MAC, vsock CID,
ssh host key, known_hosts pin, polkit rule, `vm` command entry, claude state
dir, workspace trust) is derived from it. Don't touch the module unless the
user asks.

## 1. Resolve the workspace

- Expand to an absolute path under `/home/lucasfa`, without a trailing slash.
- Check it exists with `test -d`. The sandbox hides most of `/home`, so if the
  check is blocked, don't unsandbox it: tell the user you couldn't verify the
  path. A missing dir is not fatal: tmpfiles creates it empty (owned by
  lucasfa) on switch, but confirm with the user that's what they want.
- Refuse `/home/lucasfa` itself, any ancestor of it, and anything containing
  `~/vms` (that would expose other VMs' claude state). Warn, but allow, if it
  is or contains this repo: the agent could then edit the host's own config.
- If it lies inside or contains another VM's workspace, point that out: both
  VMs would write the same files, and `vm` picks the innermost workspace.

## 2. Pick a name and index

- Name: the user's, else derived from the directory's basename: lowercase,
  keep `[a-z0-9-]`, drop leading digits/`_`/`-` (e.g. `02_tfg` → `tfg`).
  It must start with a letter and be at most 12 characters (the tap interface
  is `vm-<name>`, and Linux caps interface names at 15). It becomes a hostname
  in `/etc/hosts` and an ssh `Host`, so it must not clash with an existing VM
  or a real host (`slimbook`, `server-*`). Shorten sensibly if needed and tell
  the user what you chose.
- Index: the lowest integer in 1..200 not used by any existing
  `lfa.microvm.vms.*.index` (an assertion enforces uniqueness). It sets the IP
  `192.168.83.<10+index>`.

## 3. Edit the host config

Add the entry next to the existing ones in
`hosts/slimbook-hero/software/default.nix`, with the workspace written relative
to the user's home like the others:

```nix
    vms.<name> = {
      index = <n>;
      workspace = "${config.users.users.lucasfa.home}/<path relative to home>";
    };
```

Omit `workspace` only if the user wants the default `~/vms/<name>/workspace`.
Set `vcpu` (default 6) or `mem` (MiB ceiling, default 6144) only if asked.

## 4. Verify

Flake evaluation needs the Nix daemon, so these two run unsandboxed (they only
format and build, nothing is activated):

1. `nix fmt`
2. `nixos-rebuild build --flake .#slimbook`

If the build fails, fix it and rebuild. Optionally show what changed with
`nvd diff /run/current-system result` (if `nvd` is missing, get it with
`nix-fetch nvd` and call it by its full store path).

Don't switch and don't commit unless asked.

## 5. Report

Tell the user the name, index/IP and workspace, then how to use it:

- Apply: `sudo nixos-rebuild switch --flake .#slimbook` (or `nh os switch`).
- Then `cd <workspace> && vm` (or `vm <name>` from anywhere) to start the VM and
  run claude in it; `vm shell <name>`, `vm stop <name>`, `vm status`.
- The first `vm` after the switch boots the VM and generates its ssh host key;
  claude inside logs in with the shared token, no onboarding.
- The VM has no git credentials: commits are pushed from the host.
