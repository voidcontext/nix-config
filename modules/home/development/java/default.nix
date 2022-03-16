{ lib, pkgs, config, ... }:

with lib;
let cfg = config.development.java;
in
{
  options.development.java.jdk = mkOption {
    type = types.package;
  };

  config = mkIf (config.development.scala.enable || config.development.clojure.enable) {
    programs.zsh.initExtra = ''
      export JAVA_HOME="${cfg.jdk.home}"
    '';

    home.file.".emacs.d/init.el".text = ''
      (setenv "JAVA_HOME" "${cfg.jdk.home}")
    '';

    home.packages = [
      cfg.jdk
      pkgs.visualvm
    ];
  };
}
