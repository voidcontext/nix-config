{config, pkgs, ...}:

with builtins;

let
  xtermTheme = fetchurl {
    name = "BelafonteNight";
    url = "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/Xresources/Belafonte%20Night";
    sha256 = "12yf3a45xmi69422crxh0pk2cvc982jmg2lxks274ryl978yxxjs";
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
  home.file.".themes/BelafonteNight.Xresources".source = xtermTheme;
  home.file.".Xresources".text = ''
  #include $HOME/.themes/BelafonteNight.Xresources

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
        visibleName = "Belafonte Night - Nix";
        cursorShape = "block";
        font = "Monaco 10";
        showScrollbar = false;
        colors = {
          foregroundColor = "#96968c8c8383";
          backgroundColor = "#202011111b1b";
          boldColor = "#96968c8c8383";
          palette = [
            "#202011111b1b"
            "#bebe10100e0e"
            "#858581816262"
            "#eaeaa5a54949"
            "#42426a6a7979"
            "#979752522c2c"
            "#98989a9a9c9c"
            "#96968c8c8383"
            "#5e5e52525252"
            "#bebe10100e0e"
            "#858581816262"
            "#eaeaa5a54949"
            "#42426a6a7979"
            "#979752522c2c"
            "#98989a9a9c9c"
            "#d5d5ccccbaba"
          ];
        };
      };
    };
  };
}
