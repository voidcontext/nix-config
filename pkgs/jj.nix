{pkgs, ...}:
pkgs.writeShellScriptBin "jj" ''
  if [ "$1" == "git" ] && [ "$2" == "push" ]; then
    echo -n "Checking if pushing is safe... "
    if test -f .__DANGER__ || grep -q '!DANGER!' <<< $(jj log -r ::@); then 
      cat << EOF
  !!!DANGER!!!

  Secrets might be exposed!
  EOF
      exit 1
    fi
    echo "Done."
  fi

  ${pkgs.unstable.jujutsu}/bin/jj "$@"
''
