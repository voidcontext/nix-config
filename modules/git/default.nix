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

  programs.git = {
    enable = true;
    userName = "Gabor Pihaj";
    userEmail = "gabor.pihaj@gmail.com";
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
