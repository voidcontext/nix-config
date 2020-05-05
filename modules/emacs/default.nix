{ pkgs, hdpi ? false, ... }:

with pkgs.lib;
with builtins;

let
  extraConfig = ""
    + (readFile ./scala.el)
    + (readFile ./haskell.el)
    + (readFile ./org.el)
  ;
in
{
  home.file.".emacs.d/init.el".text =
    (replaceStrings
      ["@extraConfig@" "@font-size@"]
      [extraConfig (if hdpi then "120" else "100")]
      (readFile ./init.el));

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      # Common
      ag
      multi-term
      use-package
      zenburn-theme
      gruvbox-theme

      ace-window
      column-enforce-mode
      direnv
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
      dap-mode
      posframe

      terraform-mode

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
