{
  config,
  pkgs,
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
  imports = [
    ../../extras/hosts/Sagittarius-A.nix
  ];
  home.stateVersion = "22.11";

  base.gpg-ssh.enable = true;
  base.yubikey-tools.enable = true;

  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";
  base.git.cog.enable = true;
  base.helix.steel.enable = true;

  development.nix.enable = true;
  development.clojure.enable = true;
  development.java.jdk = pkgs.openjdk21_headless;
  development.scala.enable = true;

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.neofetch
    pkgs.vdx.gallery-manager

    # pkgs.terraform # 23.11 non free anymore

    pkgs.neomutt
    pkgs.w3m

    pkgs.opentofu

    pkgs.python3
    pkgs.nodejs
    pkgs.iperf3
    pkgs.postgresql_12
    pkgs.wireguard-tools
    pkgs.wireguard-go

    pkgs.weechat
    pkgs.lamina
    pkgs.bashInteractive
    pkgs.attic-client

    mirror-git-repo
    pkgs.exiftool

    pkgs.lima
    pkgs.colima
    pkgs.docker-client

    pkgs.kubectl
    pkgs.unstable.k9s
    pkgs.kubectx
    pkgs.fluxcd
    pkgs.kubernetes-helm

    pkgs.steel

    pkgs.unstable.prismlauncher # TODO: re-enable once it works again in 24.05
  ];

  base.darwin_symlinks = {
    "$HOME/Applications/Prismlauncher.app" = "${pkgs.unstable.prismlauncher}/Applications/Prismlauncher.app";
  };

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

      "kraz.vdx.hu" = configureSshHost {roles = ["trusted" "external"];};

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
