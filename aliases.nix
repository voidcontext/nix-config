{
  gdc		= "git diff --cached";
  gbtp		= "git branch --merged | grep -v \"\(master\|develop\|\*\)\"";
  gbpurge	= "git branch --merged | grep -v \"\(master\|develop\|\*\)\" | xargs git branch -d";
  gmf		= "git merge --ff-only";
  gmfh		= "git merge FETCH_HEAD";
  gsl		= "git shortlog -s -n";
  gitcheat	= "cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh ~/.zshrc | grep \"alias.*git\"";
}
