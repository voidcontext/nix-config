{ lib, config, pkgs, ... }:

with lib;
let cfg = config.development.rust;
in
{
  options.development.rust.enable = mkEnableOption "rust";

  config = mkIf cfg.enable {
    # emacs
    home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);

    programs.emacs.extraPackages = epkgs: with epkgs; [
      rust-mode
      toml-mode
      cargo
      flycheck-rust
    ];

    home.packages = [
      # pkgs.rustc
      # pkgs.rust-analyzer
      # pkgs.cargo

      # pkgs.rustfmt
      # pkgs.clippy

      # pkgs.cargo-outdated
      # pkgs.cargo-udeps
    ];
  };
}