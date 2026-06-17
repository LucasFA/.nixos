# AGENTS.md

## What this repo is
A NixOS + home-manager **flake** that configures four hosts: `slimbook` (desktop, unstable), `server-nuc1`, `server-hp-omen`, `server-node804` (servers on `nixos-26.05`). Host-to-role mapping lives in `flake.nix:81-86` (`hostRoles`).

## Build / verify commands
- `nix fmt` — format everything (treefmt, uses `nixfmt` + `shellcheck`; config in `modules/treefmt/default.nix`)
- `nix flake check` — runs the formatting check only (no host evaluations)
- `sudo nixos-rebuild switch --flake .#<host>` — apply config for a host (e.g. `.#slimbook`, `.#server-nuc1`)
- `nixos-rebuild build --flake . && nvd diff /run/current-system result` — alias `nixos-rbb` (see `modules/core/default.nix:43`)

## Architecture / layout
- `flake.nix` — entrypoint; defines `nixosConfigurations` and wires `nix-hardware`, `srvos`, `lanzaboote`, `agenix`, `home-manager`, `autofirma-nix`, `treefmt-nix`
- `hosts/<name>/default.nix` — per-host entrypoint; imports `hardware-configuration.nix` and `./configuration.nix` plus shared modules
- `hosts/<name>/home.nix` — per-host home-manager entrypoint; imports `modules/home/` and applies a `profiles.${hostRole}` (see `modules/home/profiles.nix`)
- `modules/core/` — shared base (user, nixpkgs, agenix, hardening, services) — imported by every host
- `modules/roles/{desktop,server}/` — role-specific nixos config, toggled via `lfa.hostRole` (enum `desktop`|`server`, default `desktop`)
- `modules/home/` — shared home-manager modules (`gnome`, `vscode`, `zed`, `mpv`, `mangohud`, `git`, `devtools`)
- `secrets/` — agenix-encrypted secrets + `secrets.nix` declaring them

## Conventions / gotchas
- `hostRole` is passed via `specialArgs` in `flake.nix` and propagated to home-manager as `extraSpecialArgs`. Always read it from args, not `config`.
- `lfa.hostRole` switches the per-host role config; servers use `nixos-stable`, desktop uses unstable — channels differ between hosts, do not assume parity.
- `nixpkgs.config.allowUnfree` is **not** set globally; an `allowUnfreePredicate` allowlist exists in `modules/core/nixpkgs.nix`. New unfree packages need to be added there.
- Custom overlay: `lucasfa-nur` provides `qc71_slimbook_laptop` kernel module used by `hosts/slimbook-hero/hardware/default.nix`.
- Locale: `en_US.UTF-8` default, but `LC_*` overridden to `es_ES.UTF-8`. TZ forced to `Atlantic/Canary` with `mkOverride 900`.
- Default shell is `fish`; `bash` auto-execs into fish for interactive non-login sessions (`modules/core/default.nix:50-59`).
- `programs.command-not-found` is disabled; `programs.nh` is enabled with `/home/lucasfa/.nixos` as the flake path.
- `result` symlink at repo root is gitignored (build artifact).
- Slimbook-only: `qc71_laptop` kernel module, NVIDIA prime, `ddcutil` for HDMI, LUKS+TPM2, lanzaboote (secure boot).
- `server-hp-omen` has `users.allowNoPasswordLogin = true` — comment warns this **requires** tailscale to avoid lockout.
- Garnix CI badge in `README.md`; `garnix.io` substituter is **commented out** in `modules/core/default.nix:123-130`.

## Secrets
Managed with **agenix**. To add one:
1. Add an entry to `secrets/secrets.nix`
2. Create the file with `agenix -e <name>` (writes `secrets/<name>.age`)
3. Reference it via `age.secrets.<name>.file = ./secrets/<name>.age;`
See `secrets/README.md` for the full pattern.

## Things an agent would miss
- There is **no live host** in `nixosConfigurations` — the commented `live` block in `flake.nix:198-208` is the only reference; don't try to build `.#live`.
- `homeConfigurations` is empty; home-manager is always wired through `nixosSystem`.
- No tests, no test runner, no pre-commit hooks. Verification = `nix flake check` (formatting) + `nixos-rebuild` (build).
- The repo has no `[host]/result` flake outputs beyond nixos configs, formatter, and the formatting check.
- `.github/workflows/update.yml` only updates `flake.lock` (manual trigger only; schedule is commented out).
