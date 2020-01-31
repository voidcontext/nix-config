{
  e = "emacs -nw";
  ec = "emacsclient -nw -a=";
  nsh = "nix-shell";

  gdc		= "git diff --cached";
  gbtp		= "git branch --merged | grep -v \"\(master\|develop\|\*\)\"";
  gbpurge	= "git branch --merged | grep -v \"\(master\|develop\|\*\)\" | xargs git branch -d";
  gmf		= "git merge --ff-only";
  gmfh		= "git merge FETCH_HEAD";
  gsl		= "git shortlog -s -n";
  gitcheat	= "cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh ~/.zshrc | grep \"alias.*git\"";

  dk="docker";
  dkps="docker ps";
  dkrma="docker rm -f $(docker ps -a -q)";

  dkc="docker-compose";
  dkce="docker-compose exec";
  dkcu="docker-compose up -d";
  dkcl="docker-compose logs";
  dkcr="docker-compose stop && docker-compose rm -f && docker-compose up";
}
