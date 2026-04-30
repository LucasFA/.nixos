{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services =
      let
        defaultService = {
          enable = true;
          description = "Update the power-profiles-daemon perf mode on boot";
          after = [ "multi-user.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = config.users.users.lucasfa.name;
          };
          script = ''
            	AC_PATH="/sys/class/power_supply/AC/online"
            	AC_STATE=$(cat "/sys/class/power_supply/AC0/online")
                case $AC_STATE in
                    "1")
                        "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
                        ;;
                    "0")
                        "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
                        ;;
                esac
          '';
        };
      in
      {
        "set-ppd-profile-on-boot" = defaultService;
      };
    # stolen from https://github.com/Straffern/config/blob/a1013f58375ea49529660a970c5d8b22f78b5272/modules/nixos/system/battery/default.nix#L74
    services.udev.extraRules = lib.mkIf config.services.power-profiles-daemon.enable ''
      # When AC adapter is plugged in - switch to performance
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
      # When AC adapter is unplugged - switch to power-saver
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    '';
  };
}
