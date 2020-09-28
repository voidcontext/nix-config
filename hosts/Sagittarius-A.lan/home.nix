{config, pkgs, ...}:

let
  # Extra zsh config to enable sdkman
  zshInit = ''
  export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  workspace = "/$HOME/workspace";
  extraAliases = {
    p = "cd " + workspace + "/personal";
    tf = "terraform";
  };

  tfswitch = pkgs.callPackage ../../modules/terraform/tfswitch.nix {};

in
{
  imports = [
    (import ../../modules/itermocil {inherit pkgs;})
    (import ../../home.nix { inherit config; inherit pkgs; inherit zshInit; inherit extraAliases; hdpi = true;})
  ];

  home.packages = [
    pkgs.gnused
    pkgs.keepassxc
    pkgs.terraform
    pkgs.visualvm
    tfswitch

    pkgs.gcc
    pkgs.bashInteractive
    pkgs.bash
    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.bwm_ng
    pkgs.postgresql_12
  ];
}
