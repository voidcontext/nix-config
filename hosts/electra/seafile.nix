{config, ...}: let
  seafileHost = "seafile.electra.lan.vdx.hu";
in {
  services.seafile.enable = true;
  services.seafile.adminEmail = "vdx@vdx.hu";
  services.seafile.initialAdminPassword = "admin1234";
  services.seafile.ccnetSettings.General.SERVICE_URL = "https://${seafileHost}";

  # Command to generate the certs:
  # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/CN=seafile.electra.lan.vdx.hu/OU=TEST/O=VDX/L=WALSALL/C=UK/' -keyout ./seafile-selfsigned.key -out ./seafile-selfsigned.crt  #
  services.nginx.virtualHosts.${seafileHost} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://seahub";
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 0;
      '';
    };
    locations."/seafhttp" = {
      proxyPass = "http://localhost:${builtins.toString config.services.seafile.seafileSettings.fileserver.port}/";
      extraConfig = ''
        rewrite ^/seafhttp(.*)$ $1 break;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  security.acme.defaults.email = "gabor.pihaj@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.certs.${seafileHost} = {
    dnsProvider = "digitalocean";
    webroot = null;
    environmentFile = "/opt/secrets/nginx/acme-do.env";
  };

  services.nginx.upstreams.seahub.servers = {
    "unix:/run/seahub/gunicorn.sock" = {};
  };

  services.dnsmasq.settings.address = [
    "/${seafileHost}/192.168.24.2"
  ];
}
