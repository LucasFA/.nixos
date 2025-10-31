{
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
}
