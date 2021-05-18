{config, pkgs, ...}:

let
  # Extra zsh config to enable sdkman
  zshInit = ''
  export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  workspace = "/$HOME/workspace";
  extraAliases = {
    p = "cd " + workspace + "/personal";
    d = "cd " + workspace + "/work";
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


  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "vscode"
  ];

  home.packages = [
    pkgs.postgresql_10
    pkgs.terraform
    pkgs.visualvm
    pkgs.vscode
    paks.awscli2
    tfswitch
  ];
}
