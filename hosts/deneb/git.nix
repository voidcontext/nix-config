{pkgs, ...}: let
  forgejo = pkgs.unstable.forgejo;
  secrets = import ./secrets.nix;
  woodpeckerPort = "8000";
  woodpeckerGRPCPort = 8001;
in {
  services.nginx.virtualHosts."git.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      access_log /var/log/nginx/git.vdx.hu-access.log;
      error_log /var/log/nginx/git.vdx.hu-error.log error;
      client_max_body_size 1G;
    '';
    locations."/" = {
      proxyPass = "http://localhost:3001/";
    };
  };

  services.nginx.virtualHosts."woodpecker.ci.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${woodpeckerPort}/";
    };
  };

  services.gitea = {
    enable = true;
    package = forgejo;
    appName = "forgejo @ git.vdx.hu"; # Give the site a name
    database.type = "sqlite3";
    lfs.enable = true;
    settings.server.DOMAIN = "git.vdx.hu";
    settings.server.ROOT_URL = "https://git.vdx.hu/";
    settings.server.HTTP_PORT = 3001;
    settings.server.APP_DATA_PATH = "/var/lib/gitea/data";
    settings.service.DISABLE_REGISTRATION = true;
    settings.repository.ENABLE_PUSH_CREATE_USER = true;
    settings.server.SSH_PORT = 5422;
    settings.server.LFS_START_SERVER = true;
    settings.webhooks.ALLOWED_HOST_LIST = "external,loopback";
    settings."repository.signing".SIGNING_KEY = "ECC0A3B48A928D02B41B44397BCF5D144C6C06E3";
    settings."repository.signing".SIGNING_NAME = "Forgejo @ git.vdx.hu";
    settings."repository.signing".SIGNING_EMAIL = "forgejo@vdx.hu";
    settings."repository.signing".INITIAL_COMMIT = "always";
    settings."repository.signing".CRUD_ACTIONS = "parentsigned";
    settings."repository.signing".WIKI = "never";
    settings."repository.signing".MERGES = "basesigned, commitssigned";
    settings.mailer.ENABLED = true;
    settings.mailer.FROM = "forgejo@vdx.hu";
    settings.mailer.MAILER_TYPE = "smtp";
    settings.mailer.SMTP_ADDR = "mail.vdx.hu";
    settings.mailer.SMTP_PORT = 456;
    settings.mailer.IS_TLS_ENABLED = true;
    settings.mailer.USER = "forgejo@vdx.hu";
    settings.mailer.PASSWD = secrets.git.forgejo.email.password;
  };

  services.woodpecker-server = {
    enable = true;
    package = pkgs.unstable.woodpecker-server;
    environment = {
      WOODPECKER_HOST = "https://woodpecker.ci.vdx.hu";
      WOODPECKER_OPEN = "true";
      WOODPECKER_ADMIN = "voidcontext";
      WOODPECKER_GITEA = "true";
      WOODPECKER_GITEA_URL = "https://git.vdx.hu";
      WOODPECKER_SERVER_ADDR = ":${woodpeckerPort}";
      WOODPECKER_GRPC_ADDR = ":${builtins.toString woodpeckerGRPCPort}";
      WOODPECKER_GITEA_CLIENT = secrets.woodpecker.gitea.client;
      WOODPECKER_GITEA_SECRET = secrets.woodpecker.gitea.secret;
      WOODPECKER_AGENT_SECRET = secrets.woodpecker.agent.secret;
      WOODPECKER_LOG_LEVEL = "info";
    };
  };

  # allow Woodpecker GRPC port in the VPC so that agents can connect
  networking.firewall.interfaces."ens4".allowedTCPPorts = [
    woodpeckerGRPCPort
  ];

  # allow Woodpecker GRPC port on the VPN so that agents can connect
  networking.firewall.interfaces."wg0".allowedTCPPorts = [
    woodpeckerGRPCPort
  ];

  environment.systemPackages = [
    forgejo
  ];
}
