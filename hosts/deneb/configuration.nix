{
  pkgs,
  modulesPath,
  home-manager,
  secrets,
  ...
}: let
  goaccessBin = "${pkgs.goaccess}/bin/goaccess";
  goaccessCron = domain: "*/5 * * * *      nginx    ${goaccessBin} -o /var/www/stats.vdx.hu/${domain}.html /var/log/nginx/${domain}-access.log --log-format=COMBINED --geoip-database=/opt/geoip/dbip-country-lite-2022-11.mmdb";
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
    ./backup.nix
    ./extras.nix
    ./git.nix
    ./indieweb
    ./monitoring.nix
    ./wireguard.nix
  ];

  # Login / ssh / security

  services.openssh.passwordAuthentication = false;
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
  networking.hostName = "deneb";

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
    pkgs.goaccess
    pkgs.wireguard-tools
  ];

  # services.logind.extraConfig = ''
  #   # Otherwise emacs cannot be built
  #   RuntimeDirectorySize=500M
  # '';

  nix.package = pkgs.unstable.nix;
  nix.settings.substituters = ["https://indieweb-tools.cachix.org"];
  nix.settings.trusted-public-keys = ["indieweb-tools.cachix.org-1:yPp4kg6bp8YLLEhuz/wRhEvPLuc3PJFZa5C8zEmw4es="];

  # Nginx Virtual hosts
  services.nginx.virtualHosts."vdx.hu" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/vdx.hu-access.log;
      error_log /var/log/nginx/vdx.hu-error.log error;
    '';
    locations."/" = {
      return = "301 https://gaborpihaj.com";
    };
  };

  static-sites."stats.vdx.hu" = {
    enable = true;
    domainName = "stats.vdx.hu";
    basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
    autoIndex = true;
  };

  services.nginx.virtualHosts."spellcasterhub.com" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/spellcasterhub.com-access.log;
      error_log /var/log/nginx/spellcasterhub.com-error.log error;
    '';
    # locations."/" = {
    #   proxyPass = "http://127.0.0.1:12000";
    #   proxyWebsockets = true; # needed if you need to use WebSocket
    #   extraConfig =
    #     # required when the target is also TLS server with multiple hosts
    #     "proxy_ssl_server_name on;" +
    #     # required when the server wants to use HTTP Authentication
    #     "proxy_pass_header Authorization;"
    #   ;
    # };
    # basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
  };

  # Goaccess stats

  services.cron = {
    enable = true;
    systemCronJobs = [
      (goaccessCron "gaborpihaj.com")
      (goaccessCron "beta.gaborpihaj.com")
      (goaccessCron "spellcasterhub.com")
      (goaccessCron "vdx.hu")
    ];
  };

  system.stateVersion = "21.11";
}
