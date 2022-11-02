{indieweb-tools, ...}:

let
  wormholePort = 6009;
in
{
  users.groups.indieweb = {};
  
   users.users.indieweb = {
    isSystemUser = true;
    group = "indieweb";
  };
  
  users.users.vdx.extraGroups = ["indieweb"];
  
  systemd.services.wormhole = {
    description = "Wormhole URL shortener";
    after = [ "network.target" ];

    wantedBy = [ "multi-user.target" ];
    
    environment = {
      WORMHOLE_DB_PATH = "/opt/indieweb/wormhole.db";
      WORMHOLE_HTTP_PORT = "6009";
    };

    serviceConfig = {
      Type = "simple";
      User = "indieweb";

      Group = "indieweb";
      
      ExecStart = ''
        ${indieweb-tools.packages."x86_64-linux".default}/bin/wormhole
      '';

      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  services.nginx.virtualHosts."vdx.hu" = {
    locations."/s/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString wormholePort}";
      # proxyWebsockets = true; # needed if you need to use WebSocket
      extraConfig =
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;" +
        # required when the server wants to use HTTP Authentication
        "proxy_pass_header Authorization;"
      ;
    };
  };
  
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * *      indieweb    ${indieweb-tools.packages."x86_64-linux".default}/bin/orion --config /opt/indieweb/indieweb.toml >> /var/log/indieweb-orion-cron.log"
    ];
  };
}