Technical debt:

- [ ] revert eMudhra CA blocklist (`security.pki.caCertificateBlacklist` in
      `modules/core/hardening.nix`, added 2026-10-20)
      Workaround for https://emudhra.we-have-a-problem.com/ ; also distrusts
      legitimate emSign certificates. Remove once nixpkgs' cacert/NSS update
      (NSS >= 3.131.1) reaches both nixos-unstable and nixos-26.05.
      Check: `curl https://dv-g3b-emudhra.we-have-a-problem.com/` fails without it.
