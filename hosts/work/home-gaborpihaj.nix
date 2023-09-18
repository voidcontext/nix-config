{
  pkgs,
  localPackages,
  ...
}: let
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

  virtualization.lima.enable = true;

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
        title = "PRs to review";
        filters = "is:open -author:@me ${teamReposFilter} review:none draft:false";
      }
      {
        title = "Approved PRs";
        filters = "is:open -author:@me ${teamReposFilter} review:approved";
      }
      {
        title = "Draft PRs";
        filters = "is:open -author:@me ${teamReposFilter} draft:true";
      }
      {
        title = "My PRs";
        filters = "is:open author:@me";
      }
    ];
  };

  home.packages = [
    # pkgs.unstable.terraform
    # pkgs.awscli2
    pkgs.plantuml
    pkgs.gh
    pkgs.gh-dash

    pkgs.lamina

    # extra packages
    localPackages.adr-tools
    localPackages.tfswitch
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
