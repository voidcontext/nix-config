{ lib, pkgs, config, ... }:

with lib;
let cfg = config.base;
in
{
  options.base.nixConfigFlakeDir = mkOption {
    type = types.str;
    example = "/opt/nix-config";
  };

  options.base.font.enable = mkEnableOption "base font";
  options.base.font.family = mkOption {
    type = types.str;
    example = "Iosevka";
  };

  options.base.headless = mkOption {
    type = types.bool;
  };

  options.base.hdpi = mkOption {
    type = types.bool;
  };

  config = mkMerge [
    {
      # https://github.com/nix-community/home-manager/issues/423
      environment.variables = {
        TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
      };

      environment.systemPackages = [
        pkgs.ag
        pkgs.bashInteractive
        pkgs.bwm_ng
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnupg
        pkgs.gnused
        pkgs.htop
        pkgs.jq
        pkgs.mc
        pkgs.mtr
        pkgs.nmap
        pkgs.pstree
        pkgs.pwgen
        pkgs.telnet
        pkgs.tree
        pkgs.watch
        pkgs.wget

        #modern unix
        pkgs.bat
        pkgs.delta
        pkgs.duf
        pkgs.du-dust
        pkgs.exa
      ];
    }
    (mkIf cfg.font.enable {
      fonts.enableFontDir = true;

      fonts.fonts = [
        (pkgs.nerdfonts.override {
          fonts = [ cfg.font.family ];
        })
      ];
    })
  ];
}
