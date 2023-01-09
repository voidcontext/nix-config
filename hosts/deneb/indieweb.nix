{ pkgs, ... }:

let
  urlShortenerPort = 6009;

  iwtBin = "${pkgs.indieweb-tools}/bin/iwt";

  urlShortenerBin = "${pkgs.indieweb-tools}/bin/iwt-url-shortener";

  iwtCronLog = "/var/log/indieweb/cross-publish.log";
in
{
  users.groups.indieweb = { };

  users.users.indieweb = {
    isSystemUser = true;
    group = "indieweb";
    # the home directory is needed so that indieweb can build gaborpihaj.com using nix
    # `nix build` creates a `~/.cache/nix` 
    createHome = true;
    home = "/var/indieweb";
  };

  users.users.vdx.extraGroups = [ "indieweb" ];

  systemd.services.iwt-url-shortener = {
    description = "IWT URL shortener";
    after = [ "network.target" ];

    wantedBy = [ "multi-user.target" ];

    environment = {
      IWT_URL_SHORTENER_DB_PATH = "/opt/indieweb/url-shortener.db";
      IWT_URL_SHORTENER_HTTP_PORT = builtins.toString urlShortenerPort;
    };

    serviceConfig = {
      Type = "simple";
      User = "indieweb";

      Group = "indieweb";

      ExecStart = ''
        ${urlShortenerBin}
      '';

      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  services.nginx.virtualHosts."vdx.hu" = {
    locations."/s/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString urlShortenerPort}";
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
      "*/5 * * * *      indieweb    ${iwtBin} --config /opt/indieweb/indieweb.toml cross-publish >> ${iwtCronLog} 2>&1"
    ];
  };

  services.logrotate.enable = true;
  services.logrotate.settings.indieweb-cron.enable = true;
  services.logrotate.settings.indieweb-cron.files = [ iwtCronLog ];
}
