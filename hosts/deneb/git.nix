{
  pkgs,
  pkgsUnstable,
  fetchurl,
  ...
}: {
  services.nginx.virtualHosts."git.vdx.hu" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:3001/";
    };
  };

  services.gitea = {
    enable = true;
    package = pkgsUnstable.forgejo.overrideAttrs (
      old: rec {
        pname = "forgejo";
        version = "1.18.1-0";

        src = builtins.fetchurl {
          name = "${pname}-src-${version}.tar.gz";
          # see https://codeberg.org/forgejo/forgejo/releases
          url = "https://codeberg.org/attachments/86af11d3-ff4c-4b1d-a4c6-ffa85bc99d31";
          sha256 = "20d082d55a0fc0e965888a569fa38182ed1d3c1568d13603a8efcd628b1d8371";
        };
        postInstall =
          (old.postInstall or "")
          + ''
            ln -s $out/bin/${old.pname} $out/bin/gitea
          '';
      }
    );
    appName = "forgejo @ git.vdx.hu"; # Give the site a name
    database.type = "sqlite3";
    domain = "git.vdx.hu";
    rootUrl = "https://git.vdx.hu/";
    httpPort = 3001;
    settings.service.DISABLE_REGISTRATION = true;
  };
}
