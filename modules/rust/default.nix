{ pkgs, ... }:

{
  home.packages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rls
    pkgs.rustup
    pkgs.rustfmt
  ];
}
