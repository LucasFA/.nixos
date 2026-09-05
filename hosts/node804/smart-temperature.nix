{ lib, pkgs, ... }:

let
  smartTemperature = pkgs.writeShellApplication {
    name = "update-smart-temperatures";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      smartmontools
    ];
    text = ''
      set -u

      output_dir=/run/smart-temperature
      output_file="$output_dir/status.json"

      read_disk() {
        local device="$1"
        local smart_json temperature

        smart_json=$(smartctl -Aj -n standby "$device" 2>/dev/null || true)
        temperature=$(printf '%s' "$smart_json" | jq -r '
          [.ata_smart_attributes.table[]? |
            select(.id == 190 or .id == 194) |
            .raw.value] | first // empty
        ' 2>/dev/null || true)

        if [[ "$temperature" =~ ^[0-9]+$ ]]; then
          jq -cn --argjson temperature "$temperature" '{
            temperature: $temperature,
            available: true
          }'
        else
          jq -cn '{
            temperature: null,
            available: false
          }'
        fi
      }

      hdd1=$(read_disk /dev/disk/by-id/wwn-0x5000c500e3754a20)
      hdd2=$(read_disk /dev/disk/by-id/wwn-0x5000c500ea24f562)
      updated_at=$(date --iso-8601=seconds --utc)

      payload=$(jq -cn \
        --argjson hdd1 "$hdd1" \
        --argjson hdd2 "$hdd2" \
        --arg updated_at "$updated_at" \
        '{
          hdd1_temperature: $hdd1.temperature,
          hdd1_available: $hdd1.available,
          hdd2_temperature: $hdd2.temperature,
          hdd2_available: $hdd2.available,
          updated_at: $updated_at
        }')

      temporary_file=$(mktemp "$output_dir/.status.XXXXXX")
      trap 'rm -f "$temporary_file"' EXIT
      printf '%s\n' "$payload" > "$temporary_file"
      chmod 0644 "$temporary_file"
      mv -f "$temporary_file" "$output_file"
    '';
  };
in
{
  systemd.tmpfiles.rules = [
    "d /run/smart-temperature 0755 root root -"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."server-node804" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8765;
        }
      ];
      locations."/smart-temperature.json" = {
        root = "/run/smart-temperature";
        extraConfig = ''
          default_type application/json;
        '';
      };
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8765 ];

  systemd.services.smart-temperature = {
    description = "Update HDD SMART temperatures";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe smartTemperature;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/run/smart-temperature" ];
    };
  };

  systemd.timers.smart-temperature = {
    description = "Periodically update HDD SMART temperatures";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "smart-temperature.service";
    };
  };
}
