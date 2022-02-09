{ pkgs, localPackages, ... }:

let
  workspace = "$HOME/workspace";
in
{

  programs.zsh.initExtraBeforeCompInit = ''
    eval "$(${pkgs.lima}/bin/limactl completion zsh)"
  '';

  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    d = "cd ${workspace}/work";
    tf = "terraform";
    docker = "podman";
    docker-compose = "podman-compose";
  };

  home.packages = [
    pkgs.postgresql_10
    pkgs.terraform
    pkgs.visualvm
    pkgs.awscli2
    pkgs.plantuml

    # extra packages
    localPackages.adr-tools
    localPackages.tfswitch

    # lima
    pkgs.lima
    pkgs.qemu
  ];
}
