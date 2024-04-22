{
  pkgs,
  ...
}: let
  workspace = "$HOME/workspace";
  cuopp-msg-helper = import ./scripts/cuopp-msg-helper.nix {inherit pkgs;};
  new-branch = import ./scripts/nb.nix {inherit pkgs;};
in {
  home.stateVersion = "23.05";

  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";
  base.git.cog.enable = true;
  base.helix.fromGit = true;

  development.nix.enable = true;
  development.java.jdk = pkgs.openjdk17_headless;
  development.scala.enable = true;

  programs.home-manager.enable = true;

  programs.zsh.shellAliases = {
    p = "cd ${workspace}/personal";
    d = "cd ${workspace}/work";
    tf = "terraform";
    assume = "export GRANTED_ALIAS_CONFIGURED=true && source .assume-wrapped";
    nb = "new-branch";
  };

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  home.packages = [
    pkgs.plantuml
    pkgs.colima

    pkgs.lamina

    pkgs.kubectl
    pkgs.k9s
    pkgs.kubectx
    pkgs.awscli2

    # extra packages
    cuopp-msg-helper
    new-branch
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
