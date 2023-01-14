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
        version = "1.18.0-1";

        src = builtins.fetchurl {
          name = "${pname}-src-${version}.tar.gz";
          # see https://codeberg.org/forgejo/forgejo/releases
          url = "https://codeberg.org/attachments/c829784c-3b85-4996-9dc6-09e12e40a93a";
          sha256 = "e366d1d7c4f901357284f7a3787a4e4e478fe95c18bb91c57de8bca0c8d1272f";
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
