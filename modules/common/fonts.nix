{ pkgs, fontFamily }:

let packages = pkgs.lib.optional (fontFamily != "nonexistent")
  (pkgs.nerdfonts.override {
    fonts = [ fontFamily ];
  });
in
{
  home.packages = packages;
}
