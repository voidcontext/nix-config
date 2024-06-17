{pkgs, ...}: let
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
    t = "tasker";
    ts = "tasker switch";
    tc = "tasker current";
    tl = "tasker list";
    td = "tasker delete";
    assume = "export GRANTED_ALIAS_CONFIGURED=true && source .assume-wrapped";
    nb = "new-branch";
    renice-falcon = "sudo renice 20 -p $(ps aux | grep 'falcon.Agen[t]' | awk '{print $2}')";
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

    pkgs.vdx.tasker

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
