{ pkgs, config, ... }:

let
  home = config.home.homeDirectory;
  templateDir = "${home}/.git-templates";
in
{

  home.file.".git-templates/hooks/pre-commit" = {
    source = ./pre-commit;
    executable = true;
  };

  home.file.".config/git/ignore".text = ''
  .bloop
  .bloop/*
  .envrc
  .metals
  project/metals.sbt
  '';

  programs.git = {
    enable = true;
    userName = "Gabor Pihaj";
    userEmail = "gabor.pihaj@gmail.com";
    signing = {
      signByDefault = true;
      key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";
    };
    extraConfig = {
      core = {
        pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | less -X -F";
        editor = "emacsclient -nw -a= -s git";
        hookspath = "${templateDir}/hooks";
      };
      init = {
        inherit templateDir;
      };
    };
  };
}
