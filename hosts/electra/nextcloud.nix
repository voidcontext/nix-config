{ pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.vdx.hu";
    home = "/Volumes/raid/nextcloud";
    package = pkgs.nextcloud25;
    maxUploadSize = "20G";
    https = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/Volumes/raid/config/nextcloud/.adminpassword";
      adminuser = "root";
      extraTrustedDomains = [ "nextcloud.lan.vdx.hu" ];
    };
  };

  # Command to generate the certs:
  # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/CN=nextcloud.vdx.hu/OU=TEST/O=VDX/L=WALSALL/C=UK/' -keyout ./nextcloud-selfsigned.key -out ./nextcloud-selfsigned.crt  # 
  services.nginx.virtualHosts."nextcloud.vdx.hu" = {
    serverAliases = [ "nextcloud.lan.vdx.hu" ];
    forceSSL = true;
    sslCertificate = "/opt/secrets/nextcloud/nextcloud-selfsigned.crt";
    sslCertificateKey = "/opt/secrets/nextcloud/nextcloud-selfsigned.key";
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
      # GRANT ALL ON SCHEMA public TO nextcloud; -- must be added manually
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }
  ];

  services.dnsmasq.extraConfig = ''
    address=/nextcloud.vdx.hu/192.168.24.2
    # address=/nextcloud.vdx.hu/192.168.24.2
    address=/nextcloud.lan.vdx.hu/10.24.0.2
  '';
}
