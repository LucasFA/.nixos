{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;

  # Fetches packages from the system's nixpkgs into the store and prints
  # their bin directories. Only accepts attribute names, so claude-code can
  # run it outside its sandbox without a prompt; the fetched tools are then
  # run inside the sandbox by store path.
  nix-fetch = pkgs.writeShellApplication {
    name = "nix-fetch";
    runtimeInputs = [ config.nix.package ];
    text = ''
      usage() {
        echo "usage: nix-fetch PKG... | nix-fetch --python MODULE..." >&2
        exit 2
      }
      [ $# -ge 1 ] || usage
      nixpkgs=${pkgs.path}

      if [ "$1" = --python ]; then
        shift
        [ $# -ge 1 ] || usage
        modules=""
        for m in "$@"; do
          [[ $m =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]] || {
            echo "nix-fetch: invalid module name: $m" >&2
            exit 2
          }
          modules+=" ps.$m"
        done
        out=$(nix build --no-link --print-out-paths --impure --expr \
          "with import $nixpkgs { config = { }; overlays = [ ]; }; python3.withPackages (ps: [$modules ])")
      else
        for p in "$@"; do
          [[ $p =~ ^[A-Za-z_][A-Za-z0-9_.-]*$ ]] || {
            echo "nix-fetch: invalid package name: $p" >&2
            exit 2
          }
        done
        out=$(nix build --no-link --print-out-paths -f "$nixpkgs" "$@")
      fi

      while read -r o; do
        if [ -d "$o/bin" ]; then
          echo "$o/bin"
        fi
      done <<<"$out"
    '';
  };

  claudeMd = ''
    # Missing tools on this machine (NixOS)

    This is NixOS. `pip install`, `npm install -g`, `uv`, `apt` and similar
    installers do not work, and sandboxed commands have no network access.
    When a command-line tool or Python module is missing, fetch it from
    nixpkgs instead of giving up or asking the user to install it:

    - CLI tools: run `nix-fetch <attr>...` (for example
      `nix-fetch poppler-utils qpdf`). It prints one `bin` directory per
      package. Then call the tool by its full path, e.g.
      `/nix/store/...-poppler-utils-.../bin/pdftotext file.pdf`.
    - Python modules: run `nix-fetch --python <module>...` (for example
      `nix-fetch --python pypdf pdfplumber`). It prints the `bin` directory
      of a Python environment containing them; use its `python3`.
    - Run `nix-fetch` as a bare command on its own: no pipes, redirects,
      `cd` or `&&`. Only then does it run outside the sandbox, which it
      needs in order to reach the Nix daemon.
    - Arguments are nixpkgs attribute names, which can differ from the
      command name (`pdftotext` is in `poppler-utils`, `convert`/`magick`
      in `imagemagick`).
    - Do not use `nix run` or `nix shell -c` to execute a tool: that runs
      it outside the sandbox.
  '';
in
{
  config = lib.mkIf cfg.enable {
    # Root-owned, highest-precedence claude-code settings: a project's
    # .claude/settings*.json cannot turn these off.
    environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
      inherit claudeMd;
      sandbox = {
        enabled = true;
        failIfUnavailable = true;
        excludedCommands = [ "nix-fetch *" ];
      };
      permissions = {
        blockReadsOutsideWorkingDirectories = true;
        allow = [ "Bash(nix-fetch *)" ];
        ask = [ "Bash(dangerouslyDisableSandbox:true)" ];
      };
    };

    environment.systemPackages = [
      pkgs.claude-code
      nix-fetch
    ];
  };
}
