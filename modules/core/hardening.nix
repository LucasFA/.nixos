{
  lib,
  pkgs,
  ...
}:
{
  programs.ssh = {
    kexAlgorithms = [
      "-ecdh-sha2-nistp256" # All of these are removed from the default kex list
      "ecdh-sha2-nistp384"
      "ecdh-sha2-nistp521"
      "diffie-hellman-group14-sha256"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
    ];
    hostKeyAlgorithms = [
      "-ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "ecdsa-sha2-nistp384-cert-v01@openssh.com"
      "ecdsa-sha2-nistp521-cert-v01@openssh.com"
      "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "ecdsa-sha2-nistp256"
      "ecdsa-sha2-nistp384"
      "ecdsa-sha2-nistp521"
      "sk-ecdsa-sha2-nistp256@openssh.com"
    ];
    macs = [
      "-hmac-sha1"
      "hmac-sha1-etm@openssh.com"
      "umac-64@openssh.com"
      "umac-64-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
  };

  # eMudhra intermediate CA key compromise (2026-10-20): https://emudhra.we-have-a-problem.com/
  # Remove once nixpkgs' cacert drops/blocks the affected intermediates (tracked in TODO.md).
  # cacert >= 3.131.1 already dropped emSign, and its build fails on blacklist entries it doesn't contain.
  security.pki.caCertificateBlacklist =
    lib.optional (lib.versionOlder pkgs.cacert.version "3.131.1") "emSign ECC Root CA - G3"
    ++ [ "Comodo AAA Services root" ];
}
