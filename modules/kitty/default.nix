{ pkgs, fontFamily, ... }:

{
  programs.zsh.plugins = [
    {
      name = "zsh-tab-title";
      src = pkgs.fetchFromGitHub {
        owner = "trystan2k";
        repo = "zsh-tab-title";
        rev = "v2.3.1";
        sha256 = "137mfwx52cg97qy3xvvnp8j5jns6hi20r39agms54rrwqyr1918f";
      };
    }
  ];

  programs.zsh.initExtraBeforeCompInit = ''
    # DISABLE_AUTO_TITLE="true"

    ZSH_TAB_TITLE_ADDITIONAL_TERMS='kitty'
    ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX=true
  '';

  programs.kitty = {
    enable = true;

    font.name = "${fontFamily} Nerd Font Mono";
    font.size = 13;

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
}
