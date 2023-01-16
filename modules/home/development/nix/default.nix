{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.development.nix;
in {
  options.development.nix.enable = mkEnableOption "Whether to install nix development tools";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.alejandra
      pkgs.nil
      pkgs.nix-prefetch-git
      pkgs.nixpkgs-fmt
    ];
  };
}
