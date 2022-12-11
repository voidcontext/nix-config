{pkgs, config, ...}: 

let zigbeeUser = "zigbee2mqtt";
in
{
  services.zigbee2mqtt.enable = true;
  services.zigbee2mqtt.settings = {
    permit_join = false;
    serial.port = "/dev/ttyUSB0";
    
    mqtt.server = "mqtt://localhost/1883";
    mqtt.user = zigbeeUser;
    
    frontend.port = 8080;
  };
  
  systemd.services."zigbee2mqtt.service".requires = ["mosquitto.service"];
  systemd.services."zigbee2mqtt.service".after = ["mosquitto.service"];
  
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
}