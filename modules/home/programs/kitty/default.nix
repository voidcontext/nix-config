{ lib, pkgs, pkgsUnstable, config, systemConfig, ... }:

with lib;
let kitty = pkgsUnstable.kitty;
in
{

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
      font.size = 14;

      settings = {
        tab_bar_style = "powerline";
        copy_on_select = "yes";
        macos_thicken_font = "0.3";
        macos_option_as_alt = "yes";
      };

      # theme = "Gruvbox Dark";
      extraConfig = ''
        map ctrl+shift+i debug_config

        map ctrl+cmd+t goto_layout tall
        map ctrl+cmd+s goto_layout stack
        map ctrl+cmd+g goto_layout grid
        map ctrl+cmd+a goto_layout fat
        map ctrl+cmd+p last_used_layout
        
        map cmd+shift+n launch --cwd=current

        # Move the active window in the indicated direction
        map cmd+shift+up move_window up
        map cmd+shift+left move_window left
        map cmd+shift+right move_window right
        map cmd+shift+down move_window down

        map cmd+equal change_font_size all +1.0
        map cmd+minus change_font_size all -1.0

        # Gruvbox dark
        background            #282828
        foreground            #ebdbb2

        cursor                #928374

        selection_foreground  #928374
        selection_background  #3c3836

        color0                #282828
        color8                #928374

        # red
        color1                #cc241d
        # light red
        color9                #fb4934

        # green
        color2                #98971a
        # light green
        color10               #b8bb26

        # yellow
        color3                #d79921
        # light yellow
        color11               #fabd2d

        # blue
        color4                #458588
        # light blue
        color12               #83a598

        # magenta
        color5                #b16286
        # light magenta
        color13               #d3869b

        # cyan
        color6                #689d6a
        # lighy cyan
        color14               #8ec07c

        # light gray
        color7                #a89984
        # dark gray
        color15               #928374
      '';

    };
  };
}
