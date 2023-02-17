{
  pkgs,
  localPackages,
  ...
}: let
  secrets = import ./secrets.nix;
  influx = "${pkgs.influxdb2}/bin/influx";
  gitea = "${localPackages.forgejo}/bin/gitea";
  sudo = "${pkgs.sudo}/bin/sudo";
  commonConfig = {
    repo = secrets.backup.borg-repo;
    encryption.mode = "repokey-blake2";
    encryption.passCommand = "cat /opt/secrets/borg/passphrase";
    environment.BORG_RSH = "ssh -i /root/.ssh/borgbase";
    extraArgs = "--lock-wait 3600";
    startAt = "daily";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = -1; # Keep at least one archive for each month
    };
  };
in {
  services.borgbackup.jobs = {
    mail =
      commonConfig
      // {
        paths = ["/var/vmail" "/var/dkim"];
      };
    influxdb =
      commonConfig
      // {
        paths = "/root/backup/influxdb";
        preHook = ''
          rm -rf ~/backup/influxdb
          mkdir -p ~/backup/influxdb
          cd ~/backup/

          ${influx} backup ./influxdb/ -t ${secrets.backup.influx-token}
        '';
      };
    forgejo =
      commonConfig
      // {
        paths = "/root/backup/forgejo";
        preHook = ''
          rm -rf ~/backup/forgejo
          mkdir -p ~/backup/forgejo
          chown gitea ~/backup/forgejo
          cd ~/backup/forgejo

          ${sudo} -u gitea ${gitea} dump -c /var/lib/gitea/custom/conf/app.ini -w /tmp/gitea
        '';
      };
  };

  environment.systemPackages = [
    pkgs.borgbackup
  ];
}
