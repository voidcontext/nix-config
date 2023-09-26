{
  pkgs,
  modulesPath,
  home-manager,
  secrets,
  ...
}: let
  hostSecrets = import ./secrets.nix;
in {
  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = [
    # DO NOT REMOVE THIS! Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")

    # Additional imports
    ./ci.nix
    ./monitoring.nix
    ./wireguard.nix
  ];

  # Login / ssh / security

  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.ports = [5422];
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # security.acme.email = "admin+acme@gaborpihaj.com";

  networking.firewall.allowedTCPPorts = [443];
  networking.hostName = "elnath";

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [secrets.ssh.public-keys.gpg];
  };

  # Home manager

  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    hdpi = false;
    fontFamily = "nonexistent";
    nixConfigFlakeDir = "/opt/nix-config";
  };

  # Build configuration

  environment.systemPackages = [
    pkgs.wireguard-tools
    pkgs.attic
  ];

  nix.package = pkgs.unstable.nix;
  nix.settings.trusted-substituters = ["file:///var/lib/woodpecker-agent/nix-store"];

  system.stateVersion = "22.11";

  # Nix binary Cache ----

  nix.settings.trusted-users = ["vdx"];

  # nix.settings.substituters = ["https://staging.attic.rs/attic-ci"];
  # nix.settings.trusted-public-keys = ["attic-ci:U5Sey4mUxwBXM3iFapmP0/ogODXywKLRNgRPQpEXxbo="];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      # These 2 settings were meant to fix the following startup issue:
      # Dec 01 15:12:03 electra postgres[24612]: [24612] LOG:  all server processes terminated; reinitializing
      # Dec 01 15:12:05 electra postgres[26426]: [26426] LOG:  database system was interrupted; last known up at 2022-12-01 15:06:44 G>
      # Dec 01 15:12:07 electra postgres[26426]: [26426] LOG:  database system was not properly shut down; automatic recovery in progr>
      # Dec 01 15:12:07 electra postgres[26426]: [26426] LOG:  redo starts at 3/65A42760
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  invalid record length at 3/65D905F8: wanted 24, got 0
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  redo done at 3/65D90530
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  last completed transaction was at log time 2022-12-01 15:11:48.611876+00
      # Dec 01 15:12:08 electra postgres[26426]: [26426] PANIC:  could not flush dirty data: Structure needs cleaning
      fsync = "off";
      data_sync_retry = true;
    };
    authentication = pkgs.lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
  services.postgresql.ensureDatabases = ["atticd"];

  # Setting the permissions didn't really work, so I ran manually:
  # > ALTER DATABASE atticd OWNER TO atticd;
  services.postgresql.ensureUsers = [
    {
      name = "atticd";
      ensurePermissions."DATABASE atticd" = "ALL PRIVILEGES";
      ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      ensurePermissions."ALL SEQUENCES IN SCHEMA public" = "ALL PRIVILEGES";
    }
  ];
  systemd.services.postgresql.postStart = pkgs.lib.mkAfter ''
    $PSQL atticd -tAc 'GRANT ALL ON ALL TABLES IN SCHEMA public TO atticd' || true
    $PSQL atticd -tAc 'GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO atticd' || true
  '';

  services.atticd = {
    enable = true;

    credentialsFile = "/opt/secrets/atticd.env";

    settings = {
      listen = "0.0.0.0:8010";
      database.url = "postgresql://atticd:${hostSecrets.attic.dbPassword}@localhost/atticd?currentSchema=atticd";
      storage.type = "s3";
      storage.region = "ams3";
      storage.bucket = "nix-binary-cache";
      storage.endpoint = "https://nix-binary-cache.ams3.digitaloceanspaces.com";
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
