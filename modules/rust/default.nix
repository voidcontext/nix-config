{ pkgs, ... }:

{
  home.packages = [
    pkgs.cargo
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.rustc
    pkgs.rustfmt
  ];
}
