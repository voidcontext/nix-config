{ pkgs, emacsGui, hdpi, ... }:

with pkgs.lib;
with builtins;
{
  home.file.".emacs.d/init.el".text = (readFile ./init.el) +
    (if emacsGui then ''
      (scroll-bar-mode -1)

      (set-face-attribute 'default nil
        :font "Fira Mono" :height ${ if hdpi then "120" else "100" } :weight 'regular :width 'regular)
    ''
    else "");

  home.packages = [
    pkgs.ispell
  ];

  programs.emacs = {
    enable = true;
    package =
      if emacsGui then pkgs.emacsUnstable
      else pkgs.emacsUnstable-nox;
    #package = pkgs.emacsGit;
    extraPackages = epkgs: with epkgs; [
      # Common
      ag
      multi-term
      use-package
      gruvbox-theme
      afternoon-theme
      inkpot-theme
      kaolin-themes
      vterm
      multi-vterm
      which-key

      multiple-cursors
      default-text-scale
      ace-window # switch between windows with M-o
      direnv
      expand-region
      flycheck
      git-gutter
      highlight-symbol
      magit
      rainbow-delimiters # color coded parantheses, braces, etc
      rainbow-mode # visualising color-codes like #5d7f2f
      undo-tree
      paredit

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

      plantuml-mode

      sql-indent

      # Nix
      nix-mode

      # Yaml
      yaml-mode
    ];
  };
}
