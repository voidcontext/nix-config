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
    (import ../../modules/rust {inherit pkgs;})
    (import ../../home.nix { inherit config; inherit pkgs; inherit zshInit; inherit extraAliases; hdpi = true;})
  ];

  home.packages = [
    pkgs.terraform
    pkgs.visualvm
    tfswitch

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12
  ];
}
