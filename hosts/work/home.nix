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
  };

  tfswitch = pkgs.callPackage ../../modules/terraform/tfswitch.nix {};

in
{
  imports = [
    (import ../../home.nix { inherit config; inherit pkgs; inherit zshInit; inherit extraAliases; hdpi = true;})
  ];


  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "vscode"
  ];

  home.packages = [
    # pkgs.joplin
    pkgs.keepassxc
    pkgs.postgresql_10
    pkgs.terraform
    pkgs.visualvm
    pkgs.vscode
    tfswitch
  ];
}
