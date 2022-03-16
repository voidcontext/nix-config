{ pkgs, pkgsUnstable, home-manager, ... }:
{

  # Bespoke Options

  base.font.enable = true;
  base.font.family = "Iosevka";

  base.headless = false;
  base.hdpi = true;

  base.nixConfigFlakeDir = "/Users/gaborpihaj/workspace/personal/nix-config";

  # Upstream options

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
    ];

  # https://github.com/nix-community/home-manager/issues/423
  environment.variables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };

  programs.zsh.enable = true;

  users.users.gaborpihaj.home = "/Users/gaborpihaj";

  home-manager.users.gaborpihaj = import ./Sagittarius-A.nix;

  home-manager.extraSpecialArgs = {
    inherit pkgsUnstable;
    localPackages = import ../../packages { inherit pkgs; };
    fontFamily = "Iosevka";
    jdk = pkgs.openjdk11_headless;
    emacsGui = true;
    hdpi = true;
    nixConfigFlakeDir = "/Users/gaborpihaj/workspace/personal/nix-config";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.package = pkgsUnstable.nix;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
