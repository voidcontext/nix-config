{ pkgs, pkgsUnstable, modulesPath, home-manager, nix-config-extras, blog, blog-beta, ... }:

let 
  git = "${pkgs.git}/bin/git";
  nix= "${pkgs.nix}/bin/nix";

  staticSitePreReqs = pkgs.writeScriptBin "staticsite-prereqs" ''
    set -e
    
    init_site() {
      site=$1
      group=$2
      ${pkgs.coreutils}/bin/mkdir -p /var/www/$site
      ${pkgs.coreutils}/bin/chmod 770 /var/www/$site
      ${pkgs.coreutils}/bin/chown nginx.$group /var/www/$site
    }
    
    init_site stats.vdx.hu nginx
    init_site gaborpihaj.com indieweb
    init_site beta.gaborpihaj.com indieweb
  '';
  staticsite-build = pkgs.writeScriptBin "staticsite-build" ''
    set -e
    
    if [[ "$DEBUG" == 1 ]]; then
      set -x
    fi
    
    site=$1
    commit=$2
    
    if [[ -z "$site" || -z "$commit" ]]; then
      echo "Usage: staticsite-build site commit"
      exit 1
    fi
    
    cd /opt/src/$site
    
    if [[ `git status --porcelain` ]]; then
      echo "There are local changes, exiting..."
      exit 1
    fi
    
    ${git} fetch --all
    ${git} checkout $commit
    ${nix} build --show-trace
    rsync -a -O --no-perms ./result/ /var/www/$site/
    rsync -a -O --no-perms --delete ./result/ /var/www/$site/
  '';

  goaccessBin = "${pkgs.goaccess}/bin/goaccess";
  goaccessCron = domain: 
      "*/5 * * * *      nginx    ${goaccessBin} -o /var/www/stats.vdx.hu/${domain}.html /var/log/nginx/${domain}-access.log --log-format=COMBINED --geoip-database=/opt/geoip/dbip-country-lite-2022-11.mmdb";
in
{

  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = nix-config-extras.extraModules.deneb ++
    [
      # DO NOT REMOVE THIS! Default configuration for DO droplet
      (modulesPath + "/virtualisation/digital-ocean-config.nix")

      # Additional imports
      ./indieweb.nix
      ./wireguard.nix
    ];
  
  # Login / ssh / security

  services.openssh.passwordAuthentication = false;
  services.openssh.ports = [ 5422 ];
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # security.acme.email = "admin+acme@gaborpihaj.com";

  networking.firewall.allowedTCPPorts = [ 443 ];

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000605439573"
    ];
  };

  users.users.tun = {
    isNormalUser = true;
  };

  # Home manager

  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    emacsGui = false;
    hdpi = false;
    fontFamily = "nonexistent";
    nixConfigFlakeDir = "/opt/nix-config";
  };

  # Build configuration

  environment.systemPackages = [
    pkgs.goaccess
    pkgs.wireguard-tools
    staticsite-build
  ];
  
  services.logind.extraConfig = ''
    # Otherwise emacs cannot be built
    RuntimeDirectorySize=500M
  '';

  nix.package = pkgsUnstable.nix;
  nix.settings.substituters = [ "https://indieweb-tools.cachix.org" ];
  nix.settings.trusted-public-keys = [ "indieweb-tools.cachix.org-1:yPp4kg6bp8YLLEhuz/wRhEvPLuc3PJFZa5C8zEmw4es=" ];
  
  # Nginx Virtual hosts
  services.nginx.virtualHosts."vdx.hu" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/vdx.hu-access.log;
      error_log /var/log/nginx/vdx.hu-error.log error;
    '';
  };

  services.nginx.virtualHosts."stats.vdx.hu" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/stats.vdx.hu/";
    locations."/" = {
      extraConfig = ''
        autoindex on;
      '';
    };
    extraConfig = ''
      access_log /var/log/nginx/stats.vdx.hu-access.log;
      error_log /var/log/nginx/stats.vdx.hu-error.log error;
    '';
    basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
  };

  services.nginx.virtualHosts."gaborpihaj.com" = {
    forceSSL = true;
    enableACME = true;
    root = "${blog.defaultPackage."x86_64-linux"}";
    
    extraConfig = ''
      access_log /var/log/nginx/gaborpihaj.com-access.log;
      error_log /var/log/nginx/gaborpihaj.com-error.log error;
    '';
  };
  
  services.nginx.virtualHosts."beta.gaborpihaj.com" = {
    forceSSL = true;
    enableACME = true;
    root = "${blog-beta.defaultPackage."x86_64-linux"}";
    basicAuthFile = "/opt/secrets/nginx/blog-beta.htpasswd";
    extraConfig = ''
      access_log /var/log/nginx/beta.gaborpihaj.com-access.log;
      error_log /var/log/nginx/beta.gaborpihaj.com-error.log error;
    '';
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
  
  
  systemd.services.staticsite-prereqs = {
    description = "Setup directories for static sites";
    before = [ "nginx.service" ];

    wantedBy = [ "multi-user.target" ];
    

    serviceConfig = {
      Type = "simple";
      User = "root";

      Group = "root";
      
      ExecStart = "${pkgs.bash}/bin/bash ${staticSitePreReqs}/bin/staticsite-prereqs";

    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      (goaccessCron "gaborpihaj.com")
      (goaccessCron "beta.gaborpihaj.com")
      (goaccessCron "spellcasterhub.com")
      (goaccessCron "vdx.hu")
    ];
  };
}
