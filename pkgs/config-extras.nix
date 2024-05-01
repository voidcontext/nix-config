{pkgs, ...}:
pkgs.writeShellApplication {
  name = "config-extras";
  runtimeInputs = [pkgs.unstable.jujutsu];
  text = ''
    set -e -o pipefail

    if [ "''${DEBUG:-}" == "1" ]; then
      set -x
    fi
  
    cmd=$1

    case "$cmd" in
      "sync")
        jj new
        jj desc -m "!DANGER! Exposed secrets!"
        cp -r ../nix-config-extras/default.nix extras/
        cp -r ../nix-config-extras/secrets.nix extras/
        cp -r ../nix-config-extras/hosts extras/
        touch .__DANGER__
        jj new
        ;;
      "move-in")
        revision=$2

        if [ -z "$revision" ]; then
          echo "Revision is required"
          exit 1
        fi

        jj rebase -s "$revision" -d @-
        jj rebase -s @ -d "$revision"
        ;;
      "move-out")
        revision=$2

        if [ -z "$revision" ]; then
          echo "Revision is required"
          exit 1
        fi

        jj rebase -s "''${revision}+" -d "''${revision}-"
        ;;
      *)
        echo "Unknown command $cmd"
        exit 1
        ;;
    esac
  '';
}
