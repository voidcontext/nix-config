{ pkgs, ... }:

let
  workspace = "/$HOME/workspace";

  tfswitch = import ../packages/tfswitch.nix { inherit pkgs; };
  adr-tools = import ../packages/adr-tools.nix { inherit pkgs; };
in
{

  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  programs.zsh.shellAliases = {
    p = "cd " + workspace + "/personal";
    d = "cd " + workspace + "/work";
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
    adr-tools
    tfswitch

    # podman
    pkgs.unstable.podman
    pkgs.unstable.podman-compose
    pkgs.qemu
    pkgs.xz
    pkgs.gvproxy
  ];
}
