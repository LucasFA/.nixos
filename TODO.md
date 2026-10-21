Technical debt:

- [ ] revert eMudhra CA blocklist (`security.pki.caCertificateBlacklist` in
      `modules/core/hardening.nix`, added 2026-10-20)
      Workaround for https://emudhra.we-have-a-problem.com/ ; also distrusts
      legitimate emSign certificates. Remove once nixpkgs' cacert/NSS update
      (NSS >= 3.131.1) reaches both nixos-unstable and nixos-26.05.
      Check: `curl https://dv-g3b-emudhra.we-have-a-problem.com/` fails without it.

- [ ] remove ghostty systemd unit override (`systemd.user.services."app-com.mitchellh.ghostty"`
      in `modules/roles/desktop/development.nix`, added 2026-10-21)
      Workaround for https://github.com/ghostty-org/ghostty/issues/14398 (systemd 262
      refuses the `Type=notify-reload` unit: "lacks handler for reload signal USR2").
      Remove once nixpkgs ships ghostty >= 1.4.0 (or a backport of ghostty PR #14399).
      Check: `nix eval nixpkgs#ghostty.version`.
