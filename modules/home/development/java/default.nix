{ lib, pkgs, config, ... }:

with lib;
let cfg = config.development.java;
in
{
  options.development.java.jdk = mkOption {
    type = types.package;
  };

  config = mkIf (config.development.scala.enable) {
    programs.zsh.initExtra = ''
      export JAVA_HOME="${cfg.jdk.home}"
    '';

    home.packages = [
      cfg.jdk
      pkgs.visualvm
    ];
  };
}
