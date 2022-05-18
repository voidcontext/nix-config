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
          ag
          multi-term
          use-package
          gruvbox-theme
          kaolin-themes
          moe-theme
          darktooth-theme
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

          adoc-mode

          org-kanban
        ];

      };
    }

    # Optionals
    (mkIf pkgs.stdenv.isDarwin {
      programs.zsh.initExtra = ''
        update_symlink $HOME/Applications/Emacs.app ${config.programs.emacs.finalPackage}/Applications/Emacs.app
      '';
    })

    (mkIf (!systemConfig.base.headless) {
      home.file.".emacs.d/init.el".text = ''
        (scroll-bar-mode -1)

        (set-face-attribute 'default nil
          :font "${systemConfig.base.font.family} Nerd Font Mono" :height ${ if systemConfig.base.hdpi then "140" else "120" } :weight 'regular :width 'regular)
      '';
    })
  ];
}
