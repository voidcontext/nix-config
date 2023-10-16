{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.base.helix;
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
        pkgs.marksman
        pkgs.alejandra
      ];

      home.file.".config/helix/themes/gruvbox_patched.toml".text = ''
              # Author : Jakub Bartodziej <kubabartodziej@gmail.com>
        # The theme uses the gruvbox dark palette with standard contrast: github.com/morhetz/gruvbox

        "attribute" = "aqua1"
        "keyword" = { fg = "red1" }
        "keyword.directive" = "red0"
        "namespace" = "aqua1"
        "punctuation" = "orange1"
        "punctuation.delimiter" = "orange1"
        "operator" = "purple1"
        "special" = "purple0"
        "variable.other.member" = "blue1"
        "variable" = "fg1"
        "variable.builtin" = "orange1"
        "variable.parameter" = "fg2"
        "type" = "yellow1"
        "type.builtin" = "yellow1"
        "constructor" = { fg = "purple1", modifiers = ["bold"] }
        "function" = { fg = "green1", modifiers = ["bold"] }
        "function.macro" = "aqua1"
        "function.builtin" = "yellow1"
        "tag" = "red1"
        "comment" = { fg = "gray1", modifiers = ["italic"]  }
        "constant" = { fg = "purple1" }
        "constant.builtin" = { fg = "purple1", modifiers = ["bold"] }
        "string" = "green1"
        "constant.numeric" = "purple1"
        "constant.character.escape" = { fg = "fg2", modifiers = ["bold"] }
        "label" = "aqua1"
        "module" = "aqua1"

        "diff.plus" = "green1"
        "diff.delta" = "orange1"
        "diff.minus" = "red1"

        "warning" = "orange1"
        "error" = "red1"
        "info" = "aqua1"
        "hint" = "blue1"

        "ui.background" = { bg = "bg0" }
        "ui.linenr" = { fg = "bg4" }
        "ui.linenr.selected" = { fg = "yellow1" }
        "ui.cursorline" = { bg = "bg1" }
        "ui.statusline" = { fg = "fg1", bg = "bg2" }
        "ui.statusline.normal" = { fg = "fg1", bg = "bg2" }
        "ui.statusline.insert" = { fg = "fg1", bg = "blue0" }
        "ui.statusline.select" = { fg = "fg1", bg = "orange0" }
        "ui.statusline.inactive" = { fg = "fg4", bg = "bg1" }
        "ui.popup" = { bg = "bg1" }
        "ui.window" = { bg = "bg1" }
        "ui.help" = { bg = "bg1", fg = "fg1" }
        "ui.text" = { fg = "fg1" }
        "ui.text.focus" = { fg = "fg1" }
        "ui.selection" = { bg = "bg2" }
        "ui.selection.primary" = { bg = "bg3" }
        "ui.cursor.primary" = { bg = "fg4", fg = "bg1" }
        "ui.cursor.match" = { bg = "bg3" }
        "ui.menu" = { fg = "fg1", bg = "bg2" }
        "ui.menu.selected" = { fg = "bg2", bg = "blue1", modifiers = ["bold"] }
        "ui.virtual.whitespace" = "bg2"
        "ui.virtual.ruler" = { bg = "bg1" }
        "ui.virtual.inlay-hint" = { fg = "gray1" }

        "diagnostic.warning" = { underline = { color = "orange1", style = "line" } }
        "diagnostic.error" = { underline = { color = "red1", style = "line" } }
        "diagnostic.info" = { underline = { color = "aqua1", style = "line" } }
        "diagnostic.hint" = { underline = { color = "blue1", style = "line" } }

        "markup.heading" = "aqua1"
        "markup.bold" = { modifiers = ["bold"] }
        "markup.italic" = { modifiers = ["italic"] }
        "markup.strikethrough" = { modifiers = ["crossed_out"] }
        "markup.link.url" = { fg = "green1", modifiers = ["underlined"] }
        "markup.link.text" = "red1"
        "markup.raw" = "red1"

        [palette]
        bg0 = "#282828" # main background
        bg1 = "#3c3836"
        bg2 = "#504945"
        bg3 = "#665c54"
        bg4 = "#7c6f64"

        fg0 = "#fbf1c7"
        fg1 = "#ebdbb2" # main foreground
        fg2 = "#d5c4a1"
        fg3 = "#bdae93"
        fg4 = "#a89984" # gray0

        gray0 = "#a89984"
        gray1 = "#928374"

        red0 = "#cc241d" # neutral
        red1 = "#fb4934" # bright
        green0 = "#98971a"
        green1 = "#b8bb26"
        yellow0 = "#d79921"
        yellow1 = "#fabd2f"
        blue0 = "#458588"
        blue1 = "#83a598"
        purple0 = "#b16286"
        purple1 = "#d3869b"
        aqua0 = "#689d6a"
        aqua1 = "#8ec07c"
        orange0 = "#d65d0e"
        orange1 = "#fe8019"
      '';

      programs.helix = {
        enable = true;
        settings = {
          # theme = "everforest_dark";
          # theme = "gruvbox";

          # workaround for lack of support of curly underline in zellij
          theme = "gruvbox_patched";

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
    (mkIf cfg.fromGit {
      programs.helix.package = pkgs.helixFlake;
      programs.helix.settings.editor.bufferline = "multiple";
    })
    (mkIf (!cfg.fromGit) {
      programs.helix.package = pkgs.unstable.helix;
    })
  ];
}
