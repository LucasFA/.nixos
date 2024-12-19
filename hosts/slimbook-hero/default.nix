{
  ...
}:

{
  imports = [
    "${
      builtins.fetchGit {
        url = "https://github.com/LucasFA/nixos-hardware.git";
        ref = "master";
        rev = "b0564f4a0cb20d89f3906d36ccc500c591d71922";
      }
    }/slimbook/hero/rpl_rtx"
    ./nvidia.nix
    ./filesystems.nix
    ./zram.nix
  ];
}
