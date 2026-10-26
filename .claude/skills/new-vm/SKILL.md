---
name: new-vm
description: Add a coding-agent microVM (lfa.microvm.vms.<name>) on slimbook for a project directory, so `vm` inside that directory runs claude in an isolated VM. Use whenever the user wants a microVM, agent VM or sandbox VM for a dir, repo or project, or wants claude sandboxed / isolated / running without prompts for some project, even if they don't say "microvm".
argument-hint: <project dir> [vm name]
---

Add a VM for `$ARGUMENTS` (a directory, optionally a name) to
`lfa.microvm.vms` in `hosts/slimbook-hero/software/default.nix`, next to the
existing entries. The module derives everything else from it, so leave
`modules/microvm/` alone unless asked.

```nix
    vms.<name> = {
      index = <n>;
      workspace = "${config.users.users.lucasfa.home}/<path under home>";
    };
```

- **name**: given, or from the basename (`02_tfg` → `tfg`): lowercase
  `[a-z0-9-]`, starts with a letter, ≤ 12 chars (the tap is `vm-<name>`,
  and Linux caps interface names at 15). It becomes an `/etc/hosts` entry and
  an ssh `Host`, so it can't clash with another VM or a real host (`slimbook`,
  `server-*`).
- **index**: lowest unused in 1..200.
- **workspace**: no trailing slash: `vm` finds the VM by matching `$PWD`
  against it, and claude's trust entry is keyed on it. If the user only wants
  a scratch VM with no project, omit it (defaults to `~/vms/<name>/workspace`);
  otherwise ask for a dir if none was given.
  - Refuse `~` and anything containing `~/vms`, which holds every VM's claude
    state.
  - Flag overlap with another VM's workspace (both write the same files;
    `vm` picks the innermost), and warn if it is or contains this repo (the
    agent could edit the host's config).
  - A missing dir is created empty on switch, so confirm. The sandbox hides
    `/home`: if `test -d` is blocked, say you couldn't check rather than
    unsandboxing it.

Verify with `nix fmt`, then `nixos-rebuild build --flake .#slimbook`. Both
evaluate the flake and need the Nix daemon, so run them unsandboxed; nothing
else here needs that. Don't switch or commit. Tell the user the name and
index you picked, then to `sudo nixos-rebuild switch --flake .#slimbook` and
run `vm` inside the workspace (or `vm <name>`).
