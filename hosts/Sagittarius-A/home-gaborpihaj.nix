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
  #   xargs -I {} mirror-git-repo git@github.com:voidcontext gitea@git.vdx.hu:voidcontext {}
  mirror-git-repo = pkgs.writeShellScriptBin "mirror-git-repo" ''
    set -e -o pipefail

    source=$1
    target=$2
    repo=$3


    git clone $source/$repo.git --mirror

    cd $repo.git
    git remote add target $target/$repo.git
    git push target --mirror

    cd -
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
  base.git.cog.enable = true;
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
    pkgs.wireguard-tools
    pkgs.wireguard-go

    pkgs.weechat

    mirror-git-repo
  ];

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    tf = "terraform";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "deneb.vdx.hu" = configureSshHost {roles = ["trusted" "external"];};
      "deneb.vdx.hu.gpg" = configureSshHost {
        roles = ["trusted" "external" "gpg"];
        hostname = "vdx.hu";
        userId = 1000;
      };

      "elnath.vdx.hu" = configureSshHost {roles = ["trusted" "external"];};

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
