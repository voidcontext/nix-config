{ config, pkgs, localPackages, ... }:

let
  workspace = "$HOME/workspace";
in
{

  base.zsh.gpg-ssh.enable = true;
  base.yubikey-tools.enable = true;

  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";

  development.java.jdk = pkgs.openjdk11_headless;
  development.clojure.enable = true;
  development.rust.enable = true;
  development.scala.enable = true;

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.nixpkgs-fmt
    pkgs.nix-prefetch-git
    pkgs.neofetch

    pkgs.terraform
    localPackages.tfswitch

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12

    pkgs.weechat
  ];


  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    tf = "terraform";
  };

  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      "spellcasterhub.com" = {
        port = 5422;
      };
      "vdx.hu" = {
        port = 5422;
      };
      "vdx.hu.gpg" = {
        hostname = "vdx.hu";
        user = "vdx";
        port = 5422;
        forwardAgent = true;
        remoteForwards = [
          {
            bind = { address = "/run/user/1000/gnupg/S.gpg-agent"; };
            host = { address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent"; };
          }
        ];
      };
      "electra.lan.gpg" = {
        hostname = "electra.lan";
        user = "vdx";
        forwardAgent = true;
        remoteForwards = [
          {
            bind = { address = "/run/user/1008/gnupg/S.gpg-agent"; };
            host = { address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent"; };
          }
        ];
      };
    };
  };
}
