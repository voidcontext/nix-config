{ pkgs, localPackages, ... }:

let
  workspace = "$HOME/workspace";
in
{
  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent
  '';

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    tf = "terraform";
  };

  home.packages = [
    pkgs.terraform
    pkgs.visualvm
    localPackages.tfswitch

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12
  ];
}
