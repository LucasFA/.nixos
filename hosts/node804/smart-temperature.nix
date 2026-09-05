{ lib, pkgs, ... }:

let
  discovery =
    id: name:
    builtins.toJSON {
      availability_topic = "PLACEHOLDER_AVAILABILITY";
      device_class = "temperature";
      device = {
        identifiers = [ "server-node804-${id}" ];
        manufacturer = "SMART";
        name = "server-node804 ${name}";
        model = "Hard disk drive";
        via_device = "server-node804";
      };
      entity_category = "diagnostic";
      name = "Temperature";
      state_class = "measurement";
      state_topic = "PLACEHOLDER_STATE";
      unique_id = "server-node804-${id}-temperature";
      unit_of_measurement = "°C";
    };

  hdd1Discovery = discovery "hdd1" "HDD 1";
  hdd2Discovery = discovery "hdd2" "HDD 2";

  smartTemperature = pkgs.writeShellApplication {
    name = "publish-smart-temperatures";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      mosquitto
      smartmontools
    ];
    text = ''
      set -u

      broker="127.0.0.1"
      base_topic="server-node804/storage"

      publish() {
        mosquitto_pub -h "$broker" -t "$1" -r -m "$2" || \
          printf 'Failed to publish MQTT topic %s\n' "$1" >&2
      }

      publish_disk() {
        id="$1"
        device="$2"
        discovery="$3"
        state_topic="$base_topic/$id/temperature"
        availability_topic="$base_topic/$id/availability"
        discovery_topic="homeassistant/sensor/server_node804_''${id}_temperature/config"

        discovery=$(printf '%s' "$discovery" | sed \
          -e "s|PLACEHOLDER_AVAILABILITY|$availability_topic|" \
          -e "s|PLACEHOLDER_STATE|$state_topic|")
        publish "$discovery_topic" "$discovery"

        if temperature=$(smartctl -Aj -n standby "$device" 2>/dev/null | \
          jq -r '[.ata_smart_attributes.table[]? |
            select(.id == 190 or .id == 194) |
            .raw.value] | first // empty'); then
          if [[ "$temperature" =~ ^[0-9]+$ ]]; then
            publish "$state_topic" "$temperature"
            publish "$availability_topic" "online"
          else
            printf 'No SMART temperature found for %s\n' "$device" >&2
            publish "$availability_topic" "offline"
          fi
        else
          printf 'SMART read failed for %s\n' "$device" >&2
          publish "$availability_topic" "offline"
        fi

      }

      publish_disk hdd1 \
        /dev/disk/by-id/wwn-0x5000c500e3754a20 \
        '${hdd1Discovery}'
      publish_disk hdd2 \
        /dev/disk/by-id/wwn-0x5000c500ea24f562 \
        '${hdd2Discovery}'
    '';
  };
in
{
  systemd.services.smart-temperature = {
    description = "Publish HDD SMART temperatures to MQTT";
    wants = [
      "network-online.target"
      "mosquitto.service"
    ];
    after = [
      "network-online.target"
      "mosquitto.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe smartTemperature;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  systemd.timers.smart-temperature = {
    description = "Periodically publish HDD SMART temperatures to MQTT";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "smart-temperature.service";
    };
  };
}
