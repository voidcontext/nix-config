{ pkgs, ... }:

with import <nixpkgs> {};
with lib;
with builtins;

let
  extraConfig = ""
    + (readFile ./scala.el)
    + (readFile ./haskell.el)
  ;
in
{
  home.file.".emacs.d/init.el".text = (replaceStrings ["@extraConfig@"] [extraConfig] (readFile ./init.el));

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      # Common
      ag
      multi-term
      use-package
      zenburn-theme

      ace-window
      column-enforce-mode
      direnv
      electric-operator
      expand-region
      flycheck
      git-gutter
      highlight-symbol
      magit
      rainbow-delimiters
      rainbow-mode
      smartparens
      undo-tree

      projectile
      treemacs
      treemacs-projectile
      treemacs-icons-dired
      treemacs-magit
      counsel
      counsel-projectile
      company
      company-lsp
      company-quickhelp
      company-restclient
      ivy
      ivy-rich
      lsp-mode
      lsp-treemacs
      lsp-mode
      lsp-ui

      # Nix
      nix-mode

      # Yaml
      yaml-mode

      # Haskell
      lsp-haskell

      # Scala
      sbt-mode
      scala-mode
    ];
  };
}
