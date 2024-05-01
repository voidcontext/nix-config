{
  lib,
  config,
  systemConfig,
  pkgs,
  ...
}:
with lib; let
  cfg = config.base.git;
  home = config.home.homeDirectory;
  templateDir = "${home}/.git-templates";
  prepare-commit-msg = import ./prepare-commit-msg.nix {inherit pkgs;};
in {
  options.base.git.enable = mkEnableOption "base.git config";

  options.base.git.name = mkOption {
    type = types.str;
  };
  options.base.git.email = mkOption {
    type = types.str;
  };
  options.base.git.sign = mkOption {
    type = types.bool;
  };
  options.base.git.signing-key = mkOption {
    type = types.str;
  };

  options.base.git.cog.enable = mkEnableOption "cocogitto conventional commits";
  options.base.git.cog.package = mkOption {
    type = types.package;
    default = pkgs.unstable.cocogitto;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages =
        [
          pkgs.delta
        ]
        ++ (lib.optional (!systemConfig.base.headless) pkgs.meld);

      home.file.".git-templates/hooks/pre-commit" = {
        source = ./pre-commit;
        executable = true;
      };

      home.file.".git-templates/hooks/prepare-commit-msg" = {
        source = "${prepare-commit-msg}/bin/${prepare-commit-msg.name}";
        executable = true;
      };

      home.file.".config/git/ignore".text = ''
        *.worksheet.sc
        .DS_Store
        .ammonite
        .bloop
        .bloop/*
        .bsp
        .dotbin
        .envrc.local
        .gittmp
        .jj
        .markdown-root
        .metals
        .nix-shell
        .sbt-hydra-history
        metals.sbt
        result
      '';

      programs.git = {
        enable = true;
        userName = cfg.name;
        userEmail = cfg.email;
        signing =
          if cfg.sign
          then {
            signByDefault = cfg.sign;
            key = cfg.signing-key;
          }
          else {
            signByDefault = false;
          };
        extraConfig = {
          core = {
            pager = "${pkgs.delta}/bin/delta";
            editor = "hx";
            hookspath = "${templateDir}/hooks";
          };
          init = {
            inherit templateDir;
          };
        };
      };

      programs.jujutsu = {
        enable = true;
        package = pkgs.unstable.jujutsu;
        settings = {
          user = {
            name = cfg.name;
            email = cfg.email;
          };
          template-aliases = {
            "format_short_id(id)" = "id.shortest()";
          };
          signing =
            if cfg.sign
            then {
              sign-all = cfg.sign;
              backend = "gpg";
              key = cfg.signing-key;
            }
            else {
              sign-all = false;
            };
          ui = {
            merge-editor = "meld";
            diff-editor = ":builtin";
          };
        };
      };
    })
    (mkIf (cfg.enable && cfg.cog.enable) {
      home.packages = [
        cfg.cog.package
      ];

      programs.zsh.initExtra = ''
        eval $(${pkgs.unstable.cocogitto}/bin/cog generate-completions zsh)
      '';

      programs.zsh.shellAliases = {
        cco = "cog commit";
        ccl = "cog changelog";
        cchl = "cog check --from-latest-tag";
        cb = "cog bump";
        cba = "cog bump --auto";
        cbad = "cog bump --auto  --dry-run";
      };
    })
  ];
}
