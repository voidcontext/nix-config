{
  pkgs,
  lib,
  config,
  localPackages,
  ...
}:
with lib; let
  cfg = config.base.helix;
  hxe = pkgs.writeShellScriptBin "hxe" ''
    ${pkgs.helixFileExplorer}/bin/hx ''$@
  '';
in {
  # Helix

  options = {
    base.helix.fromGit = mkOption {
      type = types.bool;
      default = false;
    };
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
        localPackages.marksman-bin
      ];

      programs.helix = {
        enable = true;
        settings = {
          # theme = "everforest_dark";
          theme = "gruvbox";

          editor.true-color = true;
          editor.cursorline = true;
          # editor.bufferline = "multiple";

          editor.whitespace.render = "all";
          # editor.whitespace.render.space = "all";
          # editor.whitespace.render.tab = "all";
          # editor.whitespace.render.newline = "none";

          editor.indent-guides.render = true;
          # editor.indent-guides.character = "╎";
          editor.indent-guides.character = "|";

          editor.file-picker.hidden = false;
          editor.file-picker.git-ignore = true;

          # It's quite helpful, but the placement is a bit annoying
          # editor.lsp.auto-signature-help = false;
          editor.lsp.display-messages = true;

          keys.insert.j = {k = "normal_mode";}; # Maps `jk` to exit insert mode
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
              language-servers = [
                {name = "ltex-ls";}
                {name = "marksman";}
              ];
            }
          ];
        };
      };
    }
    (mkIf cfg.fromGit {
      programs.helix.package = pkgs.helixFlake;
      programs.helix.settings.editor.bufferline = "multiple";

      home.packages = [
        hxe
      ];
    })
    (mkIf (!cfg.fromGit) {
      programs.helix.package = pkgs.unstable.helix;
    })
  ];
}
