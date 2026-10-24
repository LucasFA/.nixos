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

- [ ] clean up the old restic htpasswd symlinks once a server is up again
      (`modules/restic/server.nix`, changed 2026-10-24 in 366994b)
      The secret moved from `/mnt/pool/backups.htpasswd` to agenix's default
      `/run/agenix/restic/htpasswd`. After `nixos-rebuild switch` on server-node804
      (server-nuc1 imports the module too, where /mnt/pool is just the root fs):
      - `systemctl status restic-rest-server`, and check that a client still
        authenticates (e.g. `restic-nuc1 snapshots` on slimbook)
      - `rm /mnt/pool/backups.htpasswd` (the stale link, physically on /mnt/disk_1)
      - a second link may be hidden on the root fs under the pool mountpoint:
        `mkdir /tmp/rootfs && mount --bind / /tmp/rootfs`, remove
        `/tmp/rootfs/mnt/pool/backups.htpasswd`, then `umount /tmp/rootfs`
