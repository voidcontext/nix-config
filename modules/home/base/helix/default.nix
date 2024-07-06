{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.base.helix;
  steel-plugins =
    builtins.listToAttrs
    (builtins.map (path: {
        name = "helix/${builtins.baseNameOf path}";
        value.text = builtins.readFile path;
      })
      [
        ./helix.scm
        ./init.scm
      ]);
in {
  # Helix

  options.base.helix.steel.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkMerge [
    {
      home.file."workspace/.ignore".text = ''
        .bloop
        .bsp
        .direnv
        .idea
        .nix
        .metals

        .sass-cache
        node_modules
        target
      '';

      home.packages = [
        pkgs.ltex-ls
        # TODO: marksman is now in nixpkgs
        pkgs.marksman
        pkgs.alejandra
      ];

      programs.broot = {
        enable = true;
        settings = {
          verbs = [
            {
              invocation = "print_path";
              key = "enter";
              shortcut = "pp";
              apply_to = "file";
              leave_broot = true;
              internal = ":print_path";
            }
            {
              invocation = "create {subpath}";
              shortcut = "cr";
              leave_broot = true;
              external = "${pkgs.felis}/bin/felis open-file {directory}/{subpath}";
            }
          ];
        };
      };

      programs.helix = {
        enable = true;
        settings = {
          # theme = "everforest_dark";
          theme = "gruvbox";

          editor.true-color = true;
          editor.cursorline = true;
          editor.bufferline = "multiple";

          editor.whitespace.render = "all";
          # editor.whitespace.render.space = "all";
          # editor.whitespace.render.tab = "all";
          # editor.whitespace.render.newline = "none";

          editor.indent-guides.render = true;
          # editor.indent-guides.character = "╎";
          editor.indent-guides.character = "|";

          editor.file-picker.hidden = false;

          # It's quite helpful, but the placement is a bit annoying
          # editor.lsp.auto-signature-help = false;
          editor.lsp.display-messages = true;

          keys.insert.j = {k = "normal_mode";}; # Maps `jk` to exit insert mode

          keys.insert.up = "no_op";
          keys.insert.down = "no_op";
          keys.insert.left = "no_op";
          keys.insert.right = "no_op";
          keys.insert.pageup = "no_op";
          keys.insert.pagedown = "no_op";
          keys.insert.home = "no_op";
          keys.insert.end = "no_op";

          keys.normal.space.e = '':sh felis open-browser -l $(which broot)'';
          keys.normal.space.m = '':lsp-workspace-command build-import'';
        };
        languages = {
          language-server = {
            metals.config = {
              metals.showInferredType = true;
              isHttpEnabled = true;
            };
            ltex-ls = {
              command = "ltex-ls";
            };
            rust-analyzer.config = {
              files.excludeDirs = [".direnv"];
              check.command = "clippy";
              check.extraArgs = "--all-targets";
            };
          };
          language = [
            {
              name = "scala";
              auto-format = false;
            }
            {
              name = "nix";
              auto-format = false;
              formatter = {command = "alejandra";};
            }
            {
              name = "rust";
              auto-format = false;
            }
            {
              name = "markdown";
              auto-format = false;
              roots = [".marksman.toml" ".markdown-root"];
              language-servers = [
                {name = "ltex-ls";}
                {name = "marksman";}
              ];
            }
          ];
        };
      };
    }
    (mkIf cfg.steel.enable {
      programs.helix.package = pkgs.helix-steel;
      programs.zsh.initExtra = ''
        export STEEL_HOME="${pkgs.helix-steel}/lib/steel"
      '';
      xdg.configFile =
        steel-plugins
        // {
          "helix/helix" = {
            source = "${pkgs.helix-steel}/lib/steel";
          };
        };
    })
  ];
}
