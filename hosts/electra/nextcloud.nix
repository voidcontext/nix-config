{pkgs, ...}: {
  services.nextcloud = {
    enable = false;
    hostName = "nextcloud.vdx.hu";
    home = "/Volumes/nextcloud";
    datadir = "/Volumes/nextcloud/";
    package = pkgs.nextcloud28;
    maxUploadSize = "20G";
    https = true;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/Volumes/raid/config/nextcloud/.adminpassword";
      adminuser = "root";
      extraTrustedDomains = ["nextcloud.lan.vdx.hu"];
    };
    phpExtraExtensions = all: [all.redis];
    extraOptions = {
      "filelocking.enabled" = true;
      "memcache.local" = ''\OC\Memcache\Redis'';
      "memcache.locking" = ''\OC\Memcache\Redis'';
      redis = {
        host = "localhost";
        port = "16379";
      };
    };
  };

  services.redis.servers.nextcloud = {
    enable = false;
    port = 16379;
  };

  # Command to generate the certs:
  # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/CN=nextcloud.vdx.hu/OU=TEST/O=VDX/L=WALSALL/C=UK/' -keyout ./nextcloud-selfsigned.key -out ./nextcloud-selfsigned.crt  #
  # services.nginx.virtualHosts."nextcloud.vdx.hu" = {
  #   serverAliases = ["nextcloud.lan.vdx.hu"];
  #   forceSSL = true;
  #   sslCertificate = "/opt/secrets/nextcloud/nextcloud-selfsigned.crt";
  #   sslCertificateKey = "/opt/secrets/nextcloud/nextcloud-selfsigned.key";
  # };

  # ensure that postgres is running *before* running the setup
  # systemd.services."nextcloud-setup" = {
  #   requires = ["postgresql.service"];
  #   after = ["postgresql.service"];
  # };

  # services.postgresql.ensureDatabases = ["nextcloud"];
  # services.postgresql.ensureUsers = [
  #   {
  #     name = "nextcloud";
  #     ensureDBOwnership = true;
  #   }
  # ];

  # services.dnsmasq.settings.address = [
  #   "/nextcloud.vdx.hu/192.168.24.2"
  # ];
}
