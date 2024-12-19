{
  ...
}:

{
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/LucasFA/nixos-hardware.git";
        ref = "slimbook_hero";
        rev = "af392dd02020c0db28b23d8532f02f594708d202";
      }
    }/slimbook/hero/rpl_rtx"
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];
}
