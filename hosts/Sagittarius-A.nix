{ pkgs, localPackages, homeDirectory, ... }:

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
            host = {address = "${homeDirectory}/.gnupg/S.gpg-agent";};
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
            host = {address = "${homeDirectory}/.gnupg/S.gpg-agent";};
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
  ];
}
