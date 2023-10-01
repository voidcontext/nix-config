{
  pkgs,
  modulesPath,
  secrets,
  ...
}: {
  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = [
    # DO NOT REMOVE THIS! Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")

    # Additional imports
    ./attic.nix
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

  security.acme.email = "admin+acme@gaborpihaj.com";
  security.acme.acceptTerms = true;
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;

  networking.firewall.allowedTCPPorts = [80 443];
  networking.hostName = "elnath";

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
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

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  # Build configuration

  environment.systemPackages = [
    pkgs.wireguard-tools
    pkgs.attic-client
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

  nix.package = pkgs.unstable.nix;
  nix.settings.trusted-users = ["root" "vdx"];

  system.stateVersion = "23.05";
}
