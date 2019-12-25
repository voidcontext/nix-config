{config, pkgs, ...}:

with builtins;

let
  capabilities = rec {
    scala = true;
    haskell = true;
  };

  xtermNeutronTheme = fetchurl {
    url = "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/Xresources/Neutron";
    sha256 = "15klil1m93xsjqwp6n2hfvfdsa64kprp0qcwldzvgyllgggnl024";
  };
in
{
  imports = [
    (import ../../home.nix { inherit config;  inherit pkgs; inherit capabilities; })
  ];

  home.packages = [
    pkgs.xmobar
  ];

  home.file.".xmobar/xmobarrc".source =  ./xmobarrc;
  home.file.".xmonad/xmonad.hs".source = ./xmonad.hs;
  home.file.".themes/Neutron.Xresources".source = xtermNeutronTheme;
  home.file.".Xresources".text = ''
  #include $HOME/.themes/Neutron.Xresources

  *xterm*faceName: "Monaco for Powerline:antialias=true"
  *xterm*faceSize: 9


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
        visibleName = "Neutron - Nix";
        cursorShape = "block";
        font = "Monaco 10";
        showScrollbar = false;
        colors = {
          foregroundColor = "#e6e6e8e8efef";
          backgroundColor = "#1c1c1e1e2222";
          boldColor = "#e6e6e8e8efef";
          palette = [
            "#232325252b2b"
            "#b5b540403636"
            "#5a5ab9b97777"
            "#dedeb5b56666"
            "#6a6a7c7c9393"
            "#a4a479799d9d"
            "#3f3f9494a8a8"
            "#e6e6e8e8efef"
            "#232325252b2b"
            "#b5b540403636"
            "#5a5ab9b97777"
            "#dedeb5b56666"
            "#6a6a7c7c9393"
            "#a4a479799d9d"
            "#3f3f9494a8a8"
            "#ebebededf2f2"
          ];
        };
      };
    };
  };
}
