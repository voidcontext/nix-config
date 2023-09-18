{pkgs, ...}:
pkgs.writeShellScriptBin "cuopp-msg-helper" ''
  ref=$(git rev-parse --abbrev-ref HEAD)
  if [[ $ref =~ ^.*(CUOPP?-[0-9]+|NOJIRA)\/.* ]]
  then
    echo "[''${BASH_REMATCH[1]}] "
  fi
''
