{ lib, pkgs, config, ... }:

with lib;
let cfg = config.development.clojure;
in
{
  options.development.clojure.enable = mkEnableOption "clojure";

  config = mkIf cfg.enable {

    home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);

    programs.emacs.extraPackages = epkgs: with epkgs; [
      clojure-mode
      cider
      easy-kill
      clj-refactor
    ];

    home.packages = [
      pkgs.leiningen
    ];
  };
}
