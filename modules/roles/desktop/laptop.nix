{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lfa.roles.desktop;
  ctl = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl";
  acFile = "/sys/class/power_supply/AC0/online";
in
{
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", KERNEL=="AC0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="set-ppd-profile.service"
    '';
    systemd.services.set-ppd-profile = {
      enable = true;
      description = "Update the power-profiles-daemon perf mode";

      after = [
        "power-profiles-daemon.service"
      ];
      wants = [ "power-profiles-daemon.service" ];

      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        # User = config.users.users.lucasfa.name;
      };
      script = ''
        STATE=$(cat ${acFile})
        case $STATE in
            "1")
                ${ctl} set performance
                ;;
            "0")
                ${ctl} set power-saver
                ;;
        esac
      '';
    };
  };
}
