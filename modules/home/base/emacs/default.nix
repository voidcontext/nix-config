{ systemConfig, lib, pkgs, config, inputs, ... }:

with lib;
with builtins;
let
  package =
    if systemConfig.base.headless then pkgs.emacsUnstable-nox
    else pkgs.emacsUnstable;
in
{

  config = mkMerge [
    # Defaults
    {
      home.packages = [
        pkgs.ispell
        pkgs.zsh
      ];

      home.file.".emacs.d/init.el".text = (readFile ./init.el) + ''
        (setenv "SHELL" "${pkgs.zsh}/bin/zsh")
      '';

      programs.emacs = {
        enable = true;
        inherit package;
        #package = pkgs.emacsGit;
        overrides = self: super: {
          scala-mode = pkgs.stdenv.mkDerivation {
            name = "scala-mode";
            nativeBuildInputs = [ package ];
            src = inputs.scala-mode;
            buildPhase = ''
              ${package}/bin/emacs --batch -Q -L . -f batch-byte-compile *.el
            '';
            installPhase = ''
              mkdir -p $out/share/emacs/site-lisp
              install *.el* $out/share/emacs/site-lisp
            '';
          };
        };
        extraPackages = epkgs: with epkgs; [
          # Common
          use-package

          # General Tools
          which-key
          ag
          direnv

          # Themes
          gruvbox-theme
          kaolin-themes
          moe-theme
          darktooth-theme

          # General editor enhancements
          multiple-cursors
          default-text-scale
          undo-tree
          ace-window # switch between windows with M-o
          git-gutter
          magit
          highlight-symbol
          rainbow-delimiters # color coded parantheses, braces, etc
          rainbow-mode # visualising color-codes like #5d7f2f
          paredit

          #IDE functions
          doom-modeline
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

          #Coding
          flycheck
          lsp-mode
          lsp-treemacs
          lsp-mode
          lsp-ui
          dap-mode
          posframe
          yasnippet # this is need for implementing missing members, etc

          terraform-mode
          sql-indent
          nix-mode
          yaml-mode

          # Misc
          plantuml-mode
          adoc-mode
          org-kanban
        ];
      };

    }

    (mkIf (!systemConfig.base.headless) {
      base.darwin_symlinks = {
        "$HOME/Applications/Emacs.app" = "${config.programs.emacs.finalPackage}/Applications/Emacs.app";
      };

      home.file.".emacs.d/init.el".text = ''
        (scroll-bar-mode -1)

        (set-face-attribute 'default nil
          :font "${systemConfig.base.font.family} Nerd Font Mono" :height ${ if systemConfig.base.hdpi then "140" else "120" } :weight 'regular :width 'regular)
      '';
    })
  ];
}
