{
  lib,
  config,
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
      home.packages = [
        pkgs.delta
      ];

      home.file.".git-templates/hooks/pre-commit" = {
        source = ./pre-commit;
        executable = true;
      };

      home.file.".git-templates/hooks/prepare-commit-msg" = {
        source = "${prepare-commit-msg}/bin/${prepare-commit-msg.name}";
        executable = true;
      };

      home.file.".config/git/ignore".text = ''
        .DS_Store
        .ammonite
        .bloop
        .bloop/*
        .bsp
        .dotbin
        .envrc.local
        .metals
        .sbt-hydra-history
        .nix-shell
        .markdown-root
        metals.sbt
        result
        *.worksheet.sc
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
