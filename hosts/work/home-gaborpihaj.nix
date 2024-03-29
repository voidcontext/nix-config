{pkgs, ...}: let
  workspace = "$HOME/workspace";
  extras = import ./extras.nix;
  cuopp-msg-helper = import ./scripts/cuopp-msg-helper.nix {inherit pkgs;};
  teamReposFilter = builtins.toString (builtins.map (r: "repo:${r}") extras.teamRepos);
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
  };

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;

  xdg.configFile."gh-dash/config.yml".text = builtins.toJSON {
    prSections = [
      {
        title = "To review";
        filters = "is:open -author:@me ${teamReposFilter} review:none draft:false";
      }
      {
        title = "Approved";
        filters = "is:open -author:@me ${teamReposFilter} review:approved";
      }
      {
        title = "Changes requested";
        filters = "is:open -author:@me ${teamReposFilter} review:changes_requested";
      }
      {
        title = "Draft";
        filters = "is:open -author:@me ${teamReposFilter} draft:true";
      }
      {
        title = "My PRs";
        filters = "is:open author:@me";
      }
    ];
  };

  home.packages = [
    pkgs.plantuml
    pkgs.gh
    pkgs.gh-dash
    pkgs.colima

    pkgs.lamina

    pkgs.kubectl
    pkgs.k9s
    pkgs.kubectx

    # extra packages
    cuopp-msg-helper
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
