{ pkgs, config, inputs, ... }:

let
  zigbeeUser = "zigbee2mqtt";
  mqtt2influxdb2Setup = pkgs.writeShellScriptBin "mqtt2influxdb2-setup" ''
    mkdir -p /var/mqtt2influxdb2
    chown iot /var/mqtt2influxdb2
  '';
  mqtt2influxdb2Bin = "${inputs.mqtt2influxdb2.packages."aarch64-linux".default}/bin/mqtt2influxdb2";
in
{

  users.groups.iot = { };

  users.users.iot = {
    isSystemUser = true;
    group = "iot";
  };

  services.zigbee2mqtt.enable = true;
  services.zigbee2mqtt.settings = {
    permit_join = false;
    serial.port = "/dev/ttyUSB0";

    mqtt.server = "mqtt://localhost/1883";
    mqtt.user = zigbeeUser;

    frontend.port = 8080;
  };

  systemd.services."zigbee2mqtt.service".requires = [ "mosquitto.service" ];
  systemd.services."zigbee2mqtt.service".after = [ "mosquitto.service" ];

  services.mosquitto.enable = true;
  services.mosquitto.listeners = [
    # zigbee2mqtt
    {
      acl = [ "topic readwrite #" ];
      port = 1883;

      settings.allow_anonymous = true;

      users."${zigbeeUser}".acl = [ "readwrite #" ];
      users.vdx.acl = [ "readwrite #" ];
    }
  ];

  services.influxdb2.enable = true;

  environment.systemPackages = [
    pkgs.influxdb2
  ];

  networking.firewall.allowedTCPPorts = [
    1883 # mosquitto
    8086 # influxdb
    config.services.zigbee2mqtt.settings.frontend.port
  ];

  systemd.services.mqtt2influxdb2-setup = {
    description = "mqtt2influxdb2 setup";

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";


      ExecStart = "${mqtt2influxdb2Setup}/bin/mqtt2influxdb2-setup";

      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  systemd.services.mqtt2influxdb2 = {
    description = "MQTT to Influxdb2 forwarder";
    after = [ "mosquitto.service" "influxdb2.service" "mqtt2influxdb2-setup.service" ];

    wantedBy = [ "multi-user.target" ];

    environment = {
      MQTT2INFLUXDB2_CONFIG_FILE = "/opt/etc/mqtt2influxdb2/config.toml";
    };

    serviceConfig = {
      Type = "simple";
      User = "iot";

      Group = "iot";

      ExecStart = mqtt2influxdb2Bin;
      WorkingDirectory = "/var/mqtt2influxdb2";

      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
