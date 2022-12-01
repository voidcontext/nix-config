{pkgs, ...}:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.vdx.hu";
    home = "/Volumes/raid/nextcloud";
    package = pkgs.nextcloud24;
    maxUploadSize = "20G";
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/Volumes/raid/config/nextcloud/.adminpassword";
      adminuser = "root";
      #      extraTrustedDomains = [ "nextcloud.electra0.lan" ];
    };
  };

  services.nginx.virtualHosts."nextcloud.vdx.hu" = {
    serverAliases = [ "netxcloud.vdx.hu" ];
  };
	
  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
  
	services.postgresql.ensureDatabases = [ "nextcloud" ];
	services.postgresql.ensureUsers = [
    {
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }
	];

  services.dnsmasq.extraConfig = ''
    address=/nextcloud.vdx.hu/192.168.24.2
  '';
}
