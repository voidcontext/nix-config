{
  config,
  pkgs,
  localPackages,
  ...
}: let
  workspace = "$HOME/workspace";

  sshHostRoles = {
    trusted = {...}: {
      forwardAgent = true;
    };

    external = {...}: {
      port = 5422;
    };

    gpg = {
      userId,
      hostname,
      ...
    }: {
      inherit hostname;
      user = "vdx";
      forwardAgent = true;
      remoteForwards = [
        {
          bind = {address = "/run/user/${builtins.toString userId}/gnupg/S.gpg-agent";};
          host = {address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent";};
        }
      ];
    };
  };

  configureSshHost = {roles, ...} @ args: (builtins.foldl' (acc: role: acc // (sshHostRoles.${role} args)) {} roles);

  # usage, sync github repos that are not forks:
  # gh api -H "Accept: application/vnd.github+json" /user/repos\?affiliation=owner\&page=1 | \
  #   jq -r '.[] | select(.fork | not) | .name'                                            | \
  #   xargs -I {} sync-git-repo git@github.com:voidcontext gitea@git.vdx.hu:voidcontext {}
  sync-git-repo = pkgs.writeShellScriptBin "sync-git-repo" ''
    set -e -o pipefail

    source=$1
    target=$2
    repo=$3
  
    if [ -d $repo ]; then
      echo "Syncing $source/$repo.git to $target/$repo.git"
      cd $repo
      git remote set-url origin "$source/$repo.git"

      if [ $(git remote | grep target) ]; then  
        git remote remove target 
      fi
    else
      echo "Migrating $source/$repo.git to $target/$repo.git"

      git clone --recurse-submodules "$source/$repo.git"
      cd $repo
    fi
    git fetch --all --tags
    git remote add target "$target/$repo.git"
    # git lfs fetch --all
    git push --all target
    git push --tags target "refs/remotes/origin/*:refs/heads/*"
    # git lfs push --all origin master
    cd ..
  '';
in {
  home.stateVersion = "22.11";

  base.gpg-ssh.enable = true;
  base.yubikey-tools.enable = true;

  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";
  base.helix.fromGit = true;

  development.nix.enable = true;
  development.java.jdk = pkgs.openjdk11_headless;
  development.scala.enable = true;

  virtualization.lima.enable = true;

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.neofetch

    pkgs.terraform
    localPackages.tfswitch

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12

    pkgs.weechat

    sync-git-repo
  ];

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  programs.zsh.initExtra = ''
    export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    tf = "terraform";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "vdx.hu" = configureSshHost {roles = ["trusted" "external"];};
      "vdx.hu.gpg" = configureSshHost {
        roles = ["trusted" "external" "gpg"];
        hostname = "vdx.hu";
        userId = 1000;
      };

      "git.vdx.hu" = configureSshHost {roles = ["external"];};

      "electra.lan" = configureSshHost {roles = ["trusted"];};
      "electra.lan.gpg" = configureSshHost {
        roles = ["trusted" "gpg"];
        hostname = "electra.lan";
        userId = 1004;
      };

      "albeiro.lan" = configureSshHost {roles = ["trusted"];};
    };
  };
}
