{
  pkgs,
  pkgsUnstable,
  fetchurl,
  ...
}: 

let forgejo = pkgsUnstable.forgejo;
in
{
  services.nginx.virtualHosts."git.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:3001/";
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
  };

  environment.systemPackages = [
    forgejo
  ];
}
