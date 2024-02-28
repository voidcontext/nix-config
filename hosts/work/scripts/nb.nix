{pkgs, ...}:
pkgs.writeShellApplication {
  name = "new-branch";
  text = ''
    set -e
    if [[ "''${DEBUG:-}" == "1" ]]; then
      set -x
    fi
    if [ -z "''${1:-}" ]; then
      echo "Please provide a branch-suffix"
      exit 1
    fi

    if [ -z "''${2:-}" ]; then
      echo "Please provide a string that contains a branch number"
      exit 1
    fi

    if [ $# -gt 2 ]; then
      echo "Too many arguments"
      exit 1
    fi


    jira=""
    if [[ $2 =~ ^.*(CUOPP?-[0-9]+|NOJIRA).* ]]
    then
      jira=''${BASH_REMATCH[1]}
    fi

    if [ "$jira" == "" ]; then
      echo "the second parameter doesn't contain a valid issue number"
      exit 1
    fi

    git checkout main
    git pull
    git checkout -b "$jira/$1"
  '';
}
