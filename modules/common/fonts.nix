{ pkgs, fontFamily }:

{
  home.packages = [
    (pkgs.nerdfonts.override {
      fonts = [ fontFamily ];
    })

  ];
}
