{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.development.clojure;
in
  with lib; {
    options.development.clojure.enable = mkEnableOption "clojure";

    config = mkIf cfg.enable {
      home.packages = [
        pkgs.unstable.babashka
        pkgs.clojure
        pkgs.unstable.clojure-lsp
        pkgs.leiningen
        pkgs.rlwrap
        pkgs.unstable.cljfmt # graalvm is broken in stable
      ];
    };
  }
