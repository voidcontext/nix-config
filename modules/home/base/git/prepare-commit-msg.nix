{pkgs, ...}:
pkgs.writeShellApplication {
  name = "prepare-commit-msg";
  runtimeInputs = [pkgs.coreutils];
  text = ''
    COMMIT_MSG_FILE=$1
    COMMIT_SOURCE=''${2:-}
    SHA1=''${3:-}

    echo "Commit msg file: $COMMIT_MSG_FILE"
    echo "Commit source:   $COMMIT_SOURCE"
    echo "SHA1:            $SHA1"
    echo "MSG HELPER:      ''${GC_HOOK_COMMIT_MSG_HELPER:-}"



    if [[ -n "''${GC_HOOK_COMMIT_MSG_HELPER:-}"  && ( -z "$COMMIT_SOURCE" || "$COMMIT_SOURCE" == "message" )]]; then
        hint=$(cat "$COMMIT_MSG_FILE")
        msg=$($GC_HOOK_COMMIT_MSG_HELPER)
        echo -n "$msg"  > "$COMMIT_MSG_FILE"
        echo "$hint" >> "$COMMIT_MSG_FILE"
    fi
  '';
}
