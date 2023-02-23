{pkgsUnstable, ...}:
pkgsUnstable.forgejo.overrideAttrs (
  old: rec {
    pname = "forgejo";
    version = "1.18.5-0";

    src = builtins.fetchurl {
      name = "${pname}-src-${version}.tar.gz";
      # see https://codeberg.org/forgejo/forgejo/releases
      url = "https://codeberg.org/attachments/bb93c0c9-98c4-465c-bcff-e07ac3ee72a3";
      sha256 = "8f2689ed6fcad4d9f8e19872247643f9d28e6d4de1631ea6983cef6efad1ee0c";
    };
    # postInstall =
    #   (old.postInstall or "")
    #   + ''
    #     ln -s $out/bin/${old.pname} $out/bin/gitea
    #   '';
  }
)
