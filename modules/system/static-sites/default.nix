{
  pkgs,
  lib,
  config,
  ...
}:
# This module helps setting up static sites
# When autoRebuildGit is enabled, then
# - the site should be a buildable flake cloned into /opt/src/${domainName}
# - the repo should be owned by indieweb:indieweb
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

  git = "${pkgs.git}/bin/git";
  nix = "${pkgs.nix}/bin/nix";
  rsync = "${pkgs.rsync}/bin/rsync";
  awk = "${pkgs.gawk}/bin/awk";

  rebuild = name: afterRebuild: pkgs.writeShellScriptBin "static-site-rebuild-${name}" ''
    set -e

    SITE=$1

    if [[ "$DEBUG" == 1 ]]; then
      set -x
    fi

    if [[ -z "$SITE" ]]; then
      echo "SITE env var must be set"
      exit 1
    fi

    root_dir=/opt/src/$SITE
    dest_dir=/var/www/$SITE

    if [ ! -d $root_dir ]; then
      echo "$root_dir is not a directory, exiting..."
      exit 1
    fi

    cd $root_dir

    if [[ `git status --porcelain` ]]; then
      echo "There are local changes, exiting..."
      exit 1
    fi

    commit=$(cat $dest_dir/.commit_hash)

    ${git} fetch --all
    ${git} merge --ff-only

    current_commit=$(${git} show | head -n1 | ${awk} '{print $2}')
    if [ "$commit" == "$current_commit" ]; then
      echo "No changes, exiting..."
      exit 0
    fi

    ${nix} build --show-trace
    ${rsync} -acO --no-t --no-perms ./result/ $dest_dir
    ${rsync} -acO --no-t --no-perms --delete ./result/ $dest_dir
    echo $current_commit >> $dest_dir/.commit_hash

    ${afterRebuild}
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

    options.autoRebuildGit = mkEnableOption "Whether to auto rebuild the static site on changes";

    options.afterRebuild = mkOption {
      type = types.str;
      default = "";
    };
  };

  rebuildLogFile = config: "/var/log/static-sites/${config.domainName}-rebuild.log";
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

      services.cron.enable = true;
      services.cron.systemCronJobs =
        filter (v: v != null)
        (mapAttrsToList
          (
            name: config:
              if config.autoRebuildGit
              then "*/5 * * * *      ${config.owner} ${rebuild name config.afterRebuild}/bin/static-site-rebuild-${name} ${config.domainName} >> ${rebuildLogFile config} 2>&1"
              else null
          )
          cfg);

      services.logrotate.enable = true;
      services.logrotate.settings.static-sites-cron.enable = any (config: config.autoRebuildGit) (attrValues cfg);
      services.logrotate.settings.static-sites-cron.su = "root staticsites";
      services.logrotate.settings.static-sites-cron.files =
        filter (v: v != null)
        (mapAttrsToList
          (
            name: config:
              if config.autoRebuildGit
              then (rebuildLogFile config)
              else null
          )
          cfg);
    };
  }
