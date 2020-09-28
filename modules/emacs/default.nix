{ pkgs, hdpi ? false, ... }:

with pkgs.lib;
with builtins;

let
  extraConfig = ""
    + (readFile ./scala.el)
    + (readFile ./haskell.el)
    + (readFile ./org.el)
    + (readFile ./clojure.el)
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
    package = pkgs.emacsGit;
    extraPackages = epkgs: with epkgs; [
      # Common
      ag
      multi-term
      use-package
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
      undo-tree

      projectile
      treemacs
      treemacs-projectile
      treemacs-icons-dired
      treemacs-magit
      counsel
      counsel-projectile
      company
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
      yasnippet

      terraform-mode

      sql-indent

      # Nix
      nix-mode

      # Yaml
      yaml-mode

      # Haskell
      lsp-haskell

      # Scala
      lsp-metals
      sbt-mode
      scala-mode

      # Clojure
      clojure-mode
      clojure-mode-extra-font-locking
      cider
      paredit
      easy-kill
      clj-refactor
    ];
  };
}
