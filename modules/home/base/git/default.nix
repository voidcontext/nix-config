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

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.delta
    ];

    home.file.".git-templates/hooks/pre-commit" = {
      source = ./pre-commit;
      executable = true;
    };

    home.file.".git-templates/hooks/prepare-commit-msg" = {
      source = ./prepare-commit-msg;
      executable = true;
    };

    home.file.".config/git/ignore".text = ''
      .DS_Store
      .ammonite
      .bloop
      .bloop/*
      .bsp
      .dotbin
      .envrc
      .metals
      .sbt-hydra-history
      .nix-shell
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
  };
}
