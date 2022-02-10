{ pkgs, jdk, ... }:
{
  imports = [
    (import ../internal/java.nix { inherit pkgs jdk; })
  ];

  home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);

  programs.emacs.extraPackages = epkgs: with epkgs; [
    clojure-mode
    cider
    easy-kill
    clj-refactor
  ];

  home.packages = [
    pkgs.visualvm
    pkgs.leiningen
  ];
}
