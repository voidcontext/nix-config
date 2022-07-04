
{ pkgs, pkgsUnstable, localPackages, ... }:

let
  workspace = "$HOME/workspace";
in
{
  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";

  development.java.jdk = pkgs.openjdk11_headless;
  development.scala.enable = true;

  programs.home-manager.enable = true;

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
  };

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  home.file.".emacs.d/init.el".text = ''
    (setq org-todo-keywords
        '((sequence "TODO" "|" "DONE")
          (sequence "CODE" "PR" "UAT" "|" "PROD"))
        org-startup-indented t)
  '';

  home.packages = [
    pkgs.postgresql_10
    pkgsUnstable.terraform
    pkgs.awscli2
    pkgs.plantuml

    pkgsUnstable.lima
    pkgsUnstable.docker-client

    # extra packages
    localPackages.adr-tools
    localPackages.tfswitch
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/Users/gaborpihaj/.ssh/github_OVO7030MB.lan";
      };
    };
  };
}
