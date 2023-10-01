{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.base;
in {
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
        TERMINFO_DIRS = ["${pkgs.kitty.terminfo.outPath}/share/terminfo"];
      };

      environment.systemPackages = [
        pkgs.silver-searcher # pkgs.ag
        pkgs.bashInteractive
        pkgs.borgbackup
        pkgs.broot
        pkgs.bwm_ng
        pkgs.coreutils
        pkgs.findutils
        pkgs.git
        pkgs.git-crypt
        pkgs.gnugrep
        pkgs.gnupg
        pkgs.gnused
        pkgs.htop
        pkgs.unstable.helix
        pkgs.jq
        pkgs.mc
        pkgs.mtr
        pkgs.nmap
        pkgs.pstree
        pkgs.pwgen
        pkgs.inetutils # pkgs.telnet
        pkgs.tree
        pkgs.ncurses # for tput
        pkgs.watch
        pkgs.wget

        #modern unix
        pkgs.bat
        pkgs.bottom
        pkgs.delta
        pkgs.dogdns
        pkgs.du-dust
        pkgs.duf
        # pkgs.exa -- exa is unmaintained, eza is the maintained fork
        pkgs.unstable.eza
        pkgs.xh
      ];

      programs.zsh.enable = true;

      nix.extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
        netrc-file = /opt/attic-cache/netrc
      '';
      nix.settings.substituters = [
        "https://nix-community.cachix.org"
        "https://helix.cachix.org"
        "https://cache.nix.vdx.hu/private"
      ];
      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "private:b6wO7rXF+4WtPCocEKlbdU/bTqEdJAqRrzOu0O3cK68="
      ];
    }
    (mkIf cfg.font.enable {
      fonts.fontDir.enable = true;

      fonts.fonts = [
        (pkgs.nerdfonts.override {
          fonts = [cfg.font.family];
        })
      ];
    })
  ];
}
