{
  lib,
  pkgs,
  systemConfig,
  inputs,
  ...
}:
with lib; let
  kitty = pkgs.unstable.kitty;
  color-themes = import ./color-themes.nix {inherit inputs;};
in {
  config = mkIf (!systemConfig.base.headless) {
    base.darwin_symlinks = {
      "$HOME/Applications/kitty.app" = "${kitty}/Applications/Kitty.app";
    };

    programs.zsh.plugins = [
      {
        name = "zsh-window-title";
        src = pkgs.fetchFromGitHub {
          owner = "olets";
          repo = "zsh-window-title";
          rev = "v1.0.2";
          sha256 = "1vvzxqcfwksq429l1n6sahb18rp6pk4lss8ihn5fs8cwiw6ykwkr";
        };
      }
    ];

    programs.zsh.initExtraBeforeCompInit = ''
      DISABLE_AUTO_TITLE="true"
    '';

    programs.kitty = {
      enable = true;

      package = kitty;

      font.name = "${systemConfig.base.font.family} Nerd Font Mono";
      font.size = 15;

      settings = {
        shell_integration = "no-cursor";
        cursor_shape = "block";
        tab_bar_style = "powerline";
        copy_on_select = "yes";
        macos_thicken_font = "0";
        macos_option_as_alt = "yes";
        disable_ligatures_in = "tab cursor";
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty.sock";
      };

      # theme = "Gruvbox Dark";
      extraConfig = ''
        map ctrl+shift+i debug_config

        map ctrl+cmd+t goto_layout tall
        map ctrl+cmd+s goto_layout stack
        map ctrl+cmd+g goto_layout grid
        map ctrl+cmd+a goto_layout fat
        map ctrl+cmd+p last_used_layout

        map cmd+shift+enter launch --cwd=current

        # Move the active window in the indicated direction
        map cmd+shift+up move_window up
        map cmd+shift+left move_window left
        map cmd+shift+right move_window right
        map cmd+shift+down move_window down

        map ctrl+cmd+o pass_selection_to_program ${pkgs.felis}/bin/felis open-in-helix

        map cmd+equal change_font_size all +1.0
        map cmd+minus change_font_size all -1.0

        map ctrl+alt+1 disable_ligatures_in active always
        map ctrl+alt+2 disable_ligatures_in all never
        map ctrl+alt+3 disable_ligatures_in tab cursor

        ${color-themes.gruvbox.dark.medium}
      '';
    };
  };
}
