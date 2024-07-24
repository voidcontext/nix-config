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
        pkgs.babashka
        pkgs.clojure
        pkgs.clojure-lsp
        pkgs.leiningen
        pkgs.rlwrap
        pkgs.cljfmt
      ];
    };
  }
