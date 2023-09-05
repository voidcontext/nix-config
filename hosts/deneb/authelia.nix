{pkgs, ...}: let
  proxyConfSnippet = pkgs.writeText "proxy.conf" (builtins.readFile ./authelia/proxy.conf);
  autheliaLocationConfSnippet = pkgs.writeText "authelia-location.conf" (builtins.readFile ./authelia/authelia-location.conf);
  autheliaRequestConfSnippet = pkgs.writeText "authelia-request.conf" (builtins.readFile ./authelia/authelia-request.conf);
in {
  services.authelia.instances.mapthat-dev = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/opt/secrets/authelia/dev/storageEncryptionKeyFile";
    secrets.jwtSecretFile = "/opt/secrets/authelia/dev/jwtSecretFile";
    settings = {
      theme = "dark";
      default_redirection_url = "https://authelia.mapthat-dev.deneb.vdx.hu";
      default_2fa_method = "totp";
      log.level = "info";
      log.format = "text";
      server.host = "0.0.0.0";
      server.port = 9092;
      authentication_backend.file = {
        path = "/var/lib/authelia-mapthat-dev/users.yml";
        password.algorithm = "argon2";
      };
      session.domain = "mapthat-devel.deneb.vdx.hu";
      access_control.default_policy = "one_factor";
      notifier.filesystem = {
        filename = "/var/lib/authelia-mapthat-dev/notifications.txt";
      };
      storage.local = {
        path = "/var/lib/authelia-mapthat-dev/db.sqlite3";
      };
    };
  };

  services.nginx.virtualHosts."authelia.mapthat-devel.deneb.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:9092/";
      extraConfig = ''
        include ${proxyConfSnippet};
      '';
    };
    locations."/api/verify" = {
      proxyPass = "http://localhost:9092/";
    };
  };

  services.nginx.virtualHosts."mapthat-devel.deneb.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      access_log /var/log/nginx/mapthat-dev.deneb.vdx.hu-access.log;
      error_log /var/log/nginx/authelia-dev.deneb.vdx.hu-error.log error;

      include ${autheliaLocationConfSnippet};
    '';
    locations."/" = {
      proxyPass = "http://10.24.0.3:8010/";
      extraConfig = ''
        include ${proxyConfSnippet};
        include ${autheliaRequestConfSnippet};
      '';
    };
  };
}
