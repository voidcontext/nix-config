{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.base.helix;
  open-in-helix =
    pkgs.writeShellApplication
    {
      name = "open-in-helix";
      runtimeInputs = [pkgs.kitty];
      text = ''
        _tab_id=$1
        _file=$2

        echo "Opening $_file in tab $_tab_id"

        if [ -z "$_file" ]; then
          echo "No file has been provided"
          exit 0
        fi

        if [ ! -f "$_file" ]; then
          echo "$_file doesn't exists or not a file"
          exit 0
        fi

        kitty @ send-text --match "id:$_tab_id" '\E'
        kitty @ send-text --match "id:$_tab_id" ":open $_file"
        kitty @ send-text --match "id:$_tab_id" '\r'
        echo "Opened..."
      '';
    };
  open-in-helix-broot = pkgs.writeShellApplication {
    name = "open-in-helix-broot";
    runtimeInputs = [open-in-helix pkgs.broot];
    text = ''
      _kitty_tab_id=$1
      _root_dir=$2
      open-in-helix "$_kitty_tab_id" "$(broot "$_root_dir")"
    '';
  };
  launch-open-in-helix-broot = pkgs.writeShellApplication {
    name = "launch-open-in-helix-broot";
    runtimeInputs = [open-in-helix-broot];
    text = ''
      if [ -z "$KITTY_TAB_ID" ]; then
        echo "KITTY_TAB_ID is not set"
        exit 0
      fi

      _root_dir=$1

      kitty @ launch --type overlay ${bin open-in-helix-broot} "$KITTY_TAB_ID" "$_root_dir"
    '';
  };
  kitty-tab-id = pkgs.writeShellApplication {
    name = "kitty-tab-id";
    runtimeInputs = [pkgs.jq];
    text = ''
      if ! command -v kitty > /dev/null; then
        exit 0;
      fi

      kitty @ ls | jq '.[] | select(.is_active == true) | .tabs[] | select(.is_active == true) | .windows[] | select(.is_active == true) | .id'
    '';
  };
  bin = drv: "${drv}/bin/${drv.name}";
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
        open-in-helix
        open-in-helix-broot
        launch-open-in-helix-broot
        kitty-tab-id
      ];

      programs.zsh.shellAliases = {
        hx = "export KITTY_TAB_ID=$(kitty-tab-id) && hx";
      };

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

          keys.normal.space.e = '':sh launch-open-in-helix-broot $PWD'';
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
