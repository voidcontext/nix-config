{pkgs, ...}: let
  hostSecrets = import ./secrets.nix;
in {
  # Nix binary Cache ----
  services.nginx.virtualHosts."attic.kraz.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    serverAliases = ["cache.nix.vdx.hu"];
    extraConfig = ''
      access_log /var/log/nginx/attic.kraz.vdx.hu-access.log;
      error_log /var/log/nginx/attic.kraz.vdx.hu-error.log error;
      client_max_body_size 2G;
    '';
    locations."/" = {
      proxyPass = "http://localhost:8010";
    };
  };

  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = ["atticd_v2"];

  # Setting the permissions didn't really work, so I ran manually:
  # > ALTER DATABASE atticd OWNER TO atticd;
  services.postgresql.ensureUsers = [
    {
      name = "atticd";
      ensurePermissions."DATABASE atticd_v2" = "ALL PRIVILEGES";
      ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      ensurePermissions."ALL SEQUENCES IN SCHEMA public" = "ALL PRIVILEGES";
    }
  ];
  systemd.services.postgresql.postStart = pkgs.lib.mkAfter ''
    $PSQL atticd_v2 -tAc 'GRANT ALL ON ALL TABLES IN SCHEMA public TO atticd' || true
    $PSQL atticd_v2 -tAc 'GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO atticd' || true
    $PSQL atticd_v2 -tAc 'ALTER DATABASE atticd_v2 OWNER TO atticd' || true
    $PSQL atticd_v2 -tAc "ALTER USER atticd WITH PASSWORD '${hostSecrets.attic.dbPassword}'" || true
  '';

  services.atticd = {
    enable = true;

    credentialsFile = "/opt/secrets/atticd.env";

    settings = {
      listen = "0.0.0.0:8010";
      api-endpoint = "https://attic.kraz.vdx.hu/";
      database.url = "postgresql://atticd:${hostSecrets.attic.dbPassword}@localhost/atticd_v2";

      # storage.type = "s3";
      # storage.region = "ams3";
      # storage.bucket = "nix-binary-cache";
      # storage.endpoint = "https://nix-binary-cache.ams3.digitaloceanspaces.com";

      storage.type = "local";
      storage.path = "/var/lib/atticd/storage";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
