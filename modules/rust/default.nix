{ pkgs, ... }:

{
  home.packages = [
    pkgs.rustc
    pkgs.rust-analyzer
    pkgs.cargo

    pkgs.rustfmt
    pkgs.clippy

    pkgs.cargo-outdated
    pkgs.cargo-udeps
  ];
}
