{
  ssh.public-keys.gpg = "AAAAAA-AAA";
  ssh.public-keys."gaborpihaj@Sagittarius-A.lan -> kraz remote-build" = "AAAAAA-AAA";
  ssh.public-keys."gaborpihaj@Sagittarius-A.lan -> electra remote-build" = "AAAAAA-AAA";

  wireguard.deneb.publicKey = "AAAAAA-AAA";
  wireguard.electra.publicKey = "AAAAAA-AAA";
  wireguard.KJ-XS.publicKey = "AAAAAA-AAA";
  wireguard.sagittarius-a.publicKey = "AAAAAA-AAA";
  wireguard.sagittarius-a-dev.publicKey = "AAAAAA-AAA";
  wireguard.kraz.publicKey = "AAAAAA-AAA";
  wireguard.orkaria.publicKey = "AAAAAA-AAA";
  wireguard.zs-s23-phone.publicKey = "AAAAAA-AAA";
  wireguard.mum-phone.publicKey = "AAAAAA-AAA";
  wireguard.dad-phone.publicKey = "AAAAAA-AAA";
  wireguard.luca-phone.publicKey = "AAAAAA-AAA";

  hosts = {
    kraz = {
      influxdb.telegraf-token = "AAAAAA-AAA";
      woodpecker.agent.secret = "AAAAAA-AAA";
      attic.dbPassword = "AAAAAA-AAA";
    };
    orkaria = {
      passwords.nixos = "AAAAAA-AAA";
      passwords.vdx = "AAAAAA-AAA";
    };
    electra = {
      openweathermap.app_id = "AAAAAA-AAA";
      openweathermap.city_id = "AAAAAA-AAA";
      openweathermap.city = "AAAAAA-AAA";

      influxdb.telegraf-token = "AAAAAA-AAA";
    };
    deneb = {
      influxdb.telegraf-token = "AAAAAA-AAA";

      backup.influx-token = "AAAAAA-AAA";
      backup.borg-repo = "AAAAAA-AAA";

      woodpecker.gitea.client = "AAAAAA-AAA";
      woodpecker.gitea.secret = "AAAAAA-AAA";
      woodpecker.agent.secret = "AAAAAA-AAA";

      git.forgejo.email.password = "AAAAAA-AAA";
    };
  };
}
