{
  pkgs,
  pkgsUnstable,
  inputs,
  fetchurl,
  ...
}: let
  forgejo = pkgsUnstable.forgejo;
  secrets = import ./secrets.nix;
  woodpeckerPort = "8000";
  woodpeckerGRPCPort = 8001;
in {
  imports = [
    # "${inputs.nixpkgs-unstable}/nixos/modules/services/continuous-integration/woodpecker/agents.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/continuous-integration/woodpecker/server.nix"
  ];

  services.nginx.virtualHosts."git.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
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
    domain = "git.vdx.hu";
    rootUrl = "https://git.vdx.hu/";
    httpPort = 3001;
    settings.service.DISABLE_REGISTRATION = true;
    settings.repository.ENABLE_PUSH_CREATE_USER = true;
    settings.server.SSH_PORT = 5422;
    settings.server.LFS_START_SERVER = true;
    settings.webhooks.ALLOWED_HOST_LIST = "external,loopback";
  };

  services.woodpecker-server = {
    enable = true;
    package = pkgsUnstable.woodpecker-server;
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

  environment.systemPackages = [
    forgejo
  ];
}
