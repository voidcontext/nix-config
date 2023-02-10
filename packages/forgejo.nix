{pkgsUnstable, ...}:
pkgsUnstable.forgejo.overrideAttrs (
  old: rec {
    pname = "forgejo";
    version = "1.18.3-0";

    src = builtins.fetchurl {
      name = "${pname}-src-${version}.tar.gz";
      # see https://codeberg.org/forgejo/forgejo/releases
      url = "https://codeberg.org/attachments/384fd9ab-7c64-4c29-9b1b-cdb803c48103";
      sha256 = "cc119dfb03c90f0edbc11bc096c72a6d01c31baa68ddd95ba5871c7da9dbb725";
    };
    postInstall =
      (old.postInstall or "")
      + ''
        ln -s $out/bin/${old.pname} $out/bin/gitea
      '';
  }
)
