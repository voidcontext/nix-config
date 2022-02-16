{config, pkgs, ...}:

{
  home.username = "vdx";
  home.homeDirectory = "/home/vdx";

  imports = [
    ../../modules/common
    ../../modules/emacs
  ];
}
