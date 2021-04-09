{
  e = "emacs -nw";
  ec = "emacsclient -nw -a= -s default";
  nsh = "nix-shell";

  enable-gpg-ssh = "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent";
  learn-gpg-cardno = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

  clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";

  java-home = "readlink -f $(which java) | xargs dirname | xargs dirname";

  gcs = "git commit -v -S";
  gdc = "git diff --cached";
  gbtp = "git branch --merged | grep -v \"\(master\|develop\|\*\)\"";
  gbpurge	= "git branch --merged | grep -v \"\(master\|develop\|\*\)\" | xargs git branch -d";
  gmf = "git merge --ff-only";
  gmfh = "git merge FETCH_HEAD";
  gsl = "git shortlog -s -n";
  gitcheat = "cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh ~/.zshrc | grep \"alias.*git\"";

  rcd="cd $(git rev-parse --show-toplevel)";
  io="itermocil";

  dk="docker";
  dkps="docker ps";
  dkrma="docker rm -f $(docker ps -a -q)";

  dkc="docker-compose";
  dkce="docker-compose exec";
  dkcu="docker-compose up -d";
  dkcl="docker-compose logs";
  dkcr="docker-compose stop && docker-compose rm -f && docker-compose up";
}
