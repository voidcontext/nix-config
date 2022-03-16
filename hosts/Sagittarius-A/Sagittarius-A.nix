{ config, pkgs, localPackages, ... }:

let
  workspace = "$HOME/workspace";
in
{

  programs.home-manager.enable = true;

  imports = [
    ../../modules/common
    ../../modules/emacs
    ../../modules/scala
    ../../modules/clojure
    ../../modules/rust
    ../../modules/lima
    ../../modules/kitty
  ];

  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent

    function update_symlink () {
      _symlink=$1
      _expected_path=$2
      _current_path=$(realpath $_symlink)
      if [ "$_expected_path" != "$_current_path" ]; then
        rm $_symlink
        ln -s $_expected_path $_symlink
      fi
    }

    update_symlink $HOME/Applications/Emacs.app ${config.programs.emacs.finalPackage}/Applications/Emacs.app
    update_symlink $HOME/Applications/kitty.app ${pkgs.kitty}/Applications/kitty.app
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
            bind = {address = "/run/user/1000/gnupg/S.gpg-agent"; };
            host = {address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent";};
          }
        ];
      };
      "electra.lan.gpg" = {
        hostname = "electra.lan";
        user = "vdx";
        forwardAgent = true;
        remoteForwards = [
          {
            bind = {address = "/run/user/1008/gnupg/S.gpg-agent"; };
            host = {address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent";};
          }
        ];
      };
    };
  };

  home.packages = [
    pkgs.terraform
    localPackages.tfswitch

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12

    pkgs.weechat
    pkgs.figlet
  ];
}
