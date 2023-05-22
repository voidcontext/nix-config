{pkgs, ...}: let
  secrets = import ./secrets.nix;
in {
  services.influxdb2.enable = true;

  services.telegraf.enable = true;

  services.telegraf.extraConfig.inputs.cpu = {};
  services.telegraf.extraConfig.inputs.mem = {};
  services.telegraf.extraConfig.inputs.disk = {};
  services.telegraf.extraConfig.outputs.influxdb_v2 = {
    urls = ["http://127.0.0.1:8086"];
    token = secrets.influxdb.telegraf-token;
    organization = "elnath";
    bucket = "monitoring";
  };

  environment.systemPackages = [
    pkgs.influxdb2
  ];

  networking.firewall.interfaces."wg0".allowedTCPPorts = [
    8086 # influxdb
  ];
}
