{
  ...
}:

{
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/LucasFA/nixos-hardware.git";
        ref = "slimbook_hero-release";
        rev = "918643ece19be45c85c9c0049958c37289570d95";
      }
    }/slimbook/hero/rpl_rtx"
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];
}
