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

    home.packages = [
      pkgs.felis
    ];

    programs.kitty = {
      enable = true;

      package = kitty;

      font.name = "${systemConfig.base.font.family} Nerd Font Mono";
      font.size = lib.mkDefault 15;

      shellIntegration.mode = "no-cursor";

      settings = {
        cursor_shape = "block";
        tab_bar_style = "powerline";
        copy_on_select = "yes";
        macos_thicken_font = "0";
        macos_option_as_alt = "yes";
        disable_ligatures = "cursor";
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

        map ctrl+cmd+o pass_selection_to_program ${pkgs.felis}/bin/felis open-file --context terminal --steel

        map cmd+equal change_font_size all +1.0
        map cmd+minus change_font_size all -1.0

        map ctrl+alt+left resize_window narrower
        map ctrl+alt+right resize_window wider
        map ctrl+alt+up resize_window taller
        map ctrl+alt+down resize_window shorter 3
        # reset all windows in the tab to default sizes
        map ctrl+alt+r resize_window reset

        ${color-themes.gruvbox.dark.medium}
      '';
    };
  };
}
