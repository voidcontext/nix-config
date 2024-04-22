{pkgs, ...}:
pkgs.writeShellScriptBin "jj" ''
  if [ -f .__DANGER__ ] && [ "$1" == "git" ] && [ "$2" == "push" ]; then
    cat << EOF
  !!!DANGER!!!

  Secrets might be exposed!
  EOF
    exit 1
  fi

  ${pkgs.unstable.jujutsu}/bin/jj "$@"
''
