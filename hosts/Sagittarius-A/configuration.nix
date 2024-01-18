{pkgs, ...}: {
  imports = [
    ./build-machines.nix
  ];

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
    pkgs.wireguard-tools
  ];

  programs.zsh.enable = true;

  users.users.gaborpihaj.home = "/Users/gaborpihaj";

  home-manager.users.gaborpihaj = import ./home-gaborpihaj.nix;

  security.pam.enableSudoTouchIdAuth = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.settings.trusted-users = ["root" "gaborpihaj"];

  # for bootstrapping the darwin builder
  # nix.extraOptions = ''
  # builders = ssh-ng://builder@linux-builder x86_64-linux /etc/nix/builder_ed25519 4 - - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=

  # builders-use-substitutes = true
  # '';

  nix.package = pkgs.unstable.nix;
}
