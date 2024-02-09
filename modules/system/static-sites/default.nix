{
  pkgs,
  lib,
  config,
  ...
}:
# This module helps setting up static sites
with builtins;
with lib; let
  cfg = config.static-sites;

  setup = pkgs.writeShellScriptBin "static-site-setup" ''
    mkdir -p /var/log/static-sites/
    chown root:staticsites /var/log/static-sites/
    chmod 775 /var/log/static-sites/
  '';

  init = pkgs.writeShellScriptBin "static-site-init" ''
    ${pkgs.coreutils}/bin/mkdir -p /var/www/$SITE
    ${pkgs.coreutils}/bin/chmod 770 /var/www/$SITE
    ${pkgs.coreutils}/bin/chown $OWNER.$GROUP /var/www/$SITE
  '';

  static-site-options = {
    options.enable = mkEnableOption "Whether the static site is enabled";

    options.domainName = mkOption {
      type = types.str;
    };

    options.owner = mkOption {
      type = types.str;
      default = "nginx";
    };

    options.group = mkOption {
      type = types.str;
      default = "nginx";
    };

    options.basicAuthFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    options.autoIndex = mkEnableOption "Whether to turn on auto indexing on the root path";
  };
in
  if pkgs.stdenv.isDarwin
  then {}
  else {
    options.static-sites = mkOption {
      type = types.attrsOf (types.submodule static-site-options);
      default = {};
    };

    config = {
      users.groups.staticsites = {};

      systemd.services =
        {
          static-sites-setup = {
            description = "Setup directories for static site cron logs";
            before = ["nginx.service"];

            wantedBy = ["multi-user.target"];

            serviceConfig = {
              Type = "simple";
              User = "root";

              Group = "root";

              ExecStart = "${setup}/bin/static-site-setup";
            };
          };
        }
        // mapAttrs'
        (name: config: {
          name = "static-site-${name}-prereqs";
          value = {
            description = "Setup directories for static site ${name}";
            before = ["nginx.service"];

            wantedBy = ["multi-user.target"];

            environment = {
              SITE = config.domainName;
              OWNER = config.owner;
              GROUP = config.group;
            };

            serviceConfig = {
              Type = "simple";
              User = "root";

              Group = "root";

              ExecStart = "${init}/bin/static-site-init";
            };
          };
        })
        cfg;

      services.nginx.virtualHosts =
        mapAttrs'
        (name: config: {
          name = "${config.domainName}";
          value = {
            forceSSL = true;
            enableACME = true;
            root = "/var/www/${config.domainName}/";
            locations."/" = {
              extraConfig =
                if config.autoIndex
                then ''
                  autoindex on;
                ''
                else "";
            };
            extraConfig = ''
              access_log /var/log/nginx/${config.domainName}-access.log;
              error_log /var/log/nginx/${config.domainName}-error.log error;
            '';
            basicAuthFile = config.basicAuthFile;
          };
        })
        cfg;
    };
  }
