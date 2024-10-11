{pkgs, ...}: {
  # Bespoke Options

  base.font.enable = true;
  base.font.family = "Iosevka";

  base.headless = false;
  base.hdpi = true;

  base.nixConfigFlakeDir = "/Users/gaborpihaj/workspace/personal/nix-config";

  # Upstream options

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
  ];

  programs.zsh.enable = true;

  users.users.gaborpihaj.home = "/Users/gaborpihaj";

  home-manager.users.gaborpihaj = import ./home-gaborpihaj.nix;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.settings.trusted-users = ["root" "gaborpihaj"];

  # dev-tools config
  # nix.settings.ssl-cert-file = "/Users/gaborpihaj/.nix-ztna-bundle.crt";

  # nix config
  security.pki.certificateFiles = [
    "/Users/gaborpihaj/workspace/work/ssl/custom-ca-bundle.pem"
  ];

  security.sudo.extraConfig = ''
    Defaults env_keep += "NIX_SSL_CERT_FILE"
  '';
}
