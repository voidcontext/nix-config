{config, pkgs, ...}:

{
  imports = [
    (import ../../home.nix { inherit config; inherit pkgs; })
    (import ../../modules/linux-desktop {inherit config; inherit pkgs;})
  ];

  home.packages = [
    pkgs.joplin
    pkgs.joplin-desktop
    pkgs.keepassxc
  ];
}
