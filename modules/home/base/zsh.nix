{
  pkgs,
  inputs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    envExtra = ''
      export NIX_IGNORE_SYMLINK_STORE=1
    '';

    initExtra = pkgs.lib.mkAfter ''
      copy_function() {
      	test -n "$(declare -f "$1")" || return
      	eval "''${_/$1/$2}"
      }

      copy_function _direnv_hook _direnv_hook__old

      _direnv_hook() {
      	_direnv_hook__old "$@" 2> >(egrep -v '^direnv: (export)')
      }

      kubeoff
      KUBE_PS1_SEPARATOR=" ctx:"
      KUBE_PS1_PREFIX=""
      KUBE_PS1_SUFFIX=" "
      KUBE_PS1_DIVIDER=" ns:"
      PROMPT='$(kube_ps1)'$PROMPT
    '';

    initExtraBeforeCompInit = ''
      DISABLE_AUTO_TITLE="true" # for the zsh-window-title plugin
    '';

    shellAliases = {
      ls = "eza";
      la = "ls -la";
      df = "duf";
      du = "dust";
      h = "hx";
      fo = "felis open-file";

      reload-zsh = "source ~/.zshrc";

      enable-gpg-ssh = "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent";
      learn-gpg-cardno = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

      java-home = "readlink -f $(which java) | xargs dirname | xargs dirname";


      dk = "docker";
      dkps = "docker ps";
      dkrma = "docker rm -f $(docker ps -a -q)";

      dkc = "docker compose";
      dkce = "docker compose exec";
      dkcu = "docker compose up -d";
      dkcl = "docker compose logs";
      dkcr = "docker compose stop && docker compose rm -f && docker compose up";

      kb = "kubectl";

      nsp = "nix search nixpkgs";
      nsu = "nix search nixpkgs-unstable";
      nr = "nix run";

      nix-flake-lock-updated = ''echo "Root input updated at" &&  cat flake.lock | jq -r '(.nodes.root.inputs | values[]) as $root_input | .nodes | to_entries | map(select(.key == $root_input))[] | ($root_input + "," + (.value.locked.lastModified | strftime("%Y-%m-%d")))'  | column -ts,'';
      git-recursive-status = ''find . -name .git -type d -printf '\n##################################\n### >>> %p\n##################################\n' -execdir git status \; -prune'';
    };

    sessionVariables = {
      EDITOR = "hx";
      PAGER = "less -R";
      PSQL_EDITOR = "hx";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = inputs.zsh-nix-shell;
      }
      {
        name = "zsh-window-title";
        src = inputs.zsh-window-title;
      }
    ];

    oh-my-zsh = {
      enable = true;
      #      theme = "lambda-mod";
      custom = "$HOME/.zsh/custom/";
      extraConfig = ''
        DISABLE_AUTO_UPDATE="true"
        zstyle ':omz:update' mode disabled
      '';
      plugins = [
        "git"
        "z"
        "kube-ps1"
      ];
    };
  };
}
