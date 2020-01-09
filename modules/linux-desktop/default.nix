{config, pkgs, ...}:

with builtins;

let
  xtermTheme = fetchurl {
    name = "Earthsong";
    url = "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/Xresources/Earthsong";
    sha256 = "1hvhqn6qrylyxmyz1icap1l2mk3741xv7b6lqymjjn4sxw5dd244";
  };
in
{
  fonts.fontconfig.enable = true;
 
  home.packages = [
    pkgs.xmobar
    pkgs.dmenu
    pkgs.fira-code
  ];

  home.file.".xmobar/xmobarrc".source =  ./xmobarrc;
  home.file.".xmonad/xmonad.hs".source = ./xmonad.hs;
  home.file.".themes/Earthsong.Xresources".source = xtermTheme;
  home.file.".Xresources".text = ''
  #include $HOME/.themes/Earthsong.Xresources

  *xterm*faceName: "Monaco for Powerline:antialias=true"
  *xterm*faceSize: 10


  Xft.dpi: 96
  Xft.antialias: 1
  Xft.hinting: 1
  Xft.hintstyle: hintslight
  Xft.rgba: rgb
  Xft.lcdfilter: lcddefault
  '';

  programs.gnome-terminal = {
    enable = true;
    showMenubar = true;
    profile = {
      "4eeb888c-f65f-432c-8ece-881255dacb3f" = {
        default = true;
        visibleName = "Earthsong nix";
        cursorShape = "block";
        font = "Monaco 10";
        showScrollbar = false;
        colors = {
          foregroundColor = "#e5e5c7c7a9a9";
          backgroundColor = "#292925252020";
          boldColor = "#e5e5c7c7a9a9";
          palette = [
            "#121214141818"
            "#c9c942423434"
            "#8585c5c54c4c"
            "#f5f5aeae2e2e"
            "#13139898b9b9"
            "#d0d063633d3d"
            "#505095955252"
            "#e5e5c6c6aaaa"
            "#67675f5f5454"
            "#ffff64645a5a"
            "#9898e0e03636"
            "#e0e0d5d56161"
            "#5f5fdadaffff"
            "#ffff92926969"
            "#8484f0f08888"
            "#f6f6f7f7ecec"
          ];
        };
      };
    };
  };
}
