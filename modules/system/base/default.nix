{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.base;
  trusted-substituters = [
    "https://nix-community.cachix.org"
    "https://helix.cachix.org"
    "https://cache.nix.vdx.hu/private"
  ];
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

      environment.systemPackages =
        (pkgs.lib.optionals pkgs.stdenv.isLinux [
          (pkgs.lib.trivial.warn "TODO: install this unconditionally once fixed on darwin" pkgs.borgbackup)
        ])
        ++ [
          pkgs.silver-searcher # pkgs.ag
          pkgs.bashInteractive
          # pkgs.borgbackup
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
          pkgs.jwt-cli

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

      nix.package = pkgs.unstable.lix;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
        netrc-file = /opt/attic-cache/netrc
        builders-use-substitutes = true
      '';
      nix.settings.substituters = trusted-substituters;
      nix.settings.trusted-substituters = trusted-substituters;
      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "private:O0/Z0BQZpKKHQQES65u7xNfZF7eCZoz9RKJi191TGaM="
      ];
    }
    (mkIf cfg.font.enable (
      let
        fonts =
          if pkgs.stdenv.isDarwin
          then {
            fonts = [
              (pkgs.nerdfonts.override {
                fonts = [cfg.font.family];
              })
            ];
          }
          else {
            packages = [
              (pkgs.nerdfonts.override {
                fonts = [cfg.font.family];
              })
            ];
          };
      in {
        fonts = fonts // {fontDir.enable = true;};
      }
    ))
  ];
}
