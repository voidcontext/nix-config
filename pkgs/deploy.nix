{pkgs, ...}:
pkgs.writeShellScriptBin "deploy" ''
  if [ ! -f .__DANGER__ ]; then
    cat << EOF
  !!!DANGER!!!

  You probably want to run this command with unlocked extras.
  EOF
    exit 1
  fi

  ${pkgs.deploy-rs-flake}/bin/deploy "$@"
''
