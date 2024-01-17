{pkgs, ...}: let
  secrets = import ./secrets.nix;
in {
  services.influxdb2 = {
    enable = true;
    provision.enable = true;
    provision.initialSetup.username = "admin";
    provision.initialSetup.passwordFile = "/opt/secrets/influxdb2/password-admin";
    provision.initialSetup.tokenFile = "/opt/secrets/influxdb2/token-admin";
    provision.initialSetup.organization = "kraz";
    provision.initialSetup.bucket = "admin";

    provision.organizations.kraz = {
      present = true;

      buckets.system.present = true;

      auths.telegraf.present = true;
      auths.telegraf.writeBuckets = ["system"];
      auths.telegraf.tokenFile = "/opt/secrets/influxdb2/token-telegraf";
    };
  };

  services.telegraf.enable = true;

  services.telegraf.extraConfig.inputs.cpu = {};
  services.telegraf.extraConfig.inputs.mem = {};
  services.telegraf.extraConfig.inputs.disk = {};
  services.telegraf.extraConfig.inputs.net = {};
  services.telegraf.extraConfig.outputs.influxdb_v2 = {
    urls = ["http://127.0.0.1:8086"];
    token = secrets.influxdb.telegraf-token;
    organization = "kraz";
    bucket = "system";
  };

  environment.systemPackages = [
    pkgs.influxdb2
  ];

  networking.firewall.interfaces."wg0".allowedTCPPorts = [
    8086 # influxdb
  ];
}
