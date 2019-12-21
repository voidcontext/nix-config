{ pkgs, capabilities , ... }:

with import <nixpkgs> {};
with lib;
with builtins;

let
  extraConfig = ""
    + (optionalString capabilities.scala (readFile ./scala.el));
in
{
  _module.args.scala = mkDefault false;

  home.file.".emacs.d/init.el".text = (replaceStrings ["@extraConfig@"] [extraConfig] (readFile ./init.el));

  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: with epkgs; [
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
    ]
    ++ optional capabilities.scala [ sbt-mode scala-mode ]);
  };
}
