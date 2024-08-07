{pkgs, ...}: {
  programs.zsh = {
    enable = true;

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

      gcs = "git commit -v -S";
      gdc = "git diff --cached";
      gbtp = "git branch --merged | grep -v \"\\(master\\|main\\|\\*\\)\"";
      gbpurge = "git branch --merged | grep -v \"\\(master\\|main\\|\\*\\)\" | xargs git branch -d";
      gmf = "git merge --ff-only";
      gmfh = "git merge FETCH_HEAD";
      gsl = "git shortlog -s -n";
      gitcheat = "cat ~/.oh-my-zsh/plugins/git/git.plugin.zsh ~/.zshrc | grep \"alias.*git\"";

      jab = "jj abandon";
      jb = "jj branch";
      jbc = "jj branch create";
      jbl = "jj branch list";
      jbs = "jj branch set";
      jco = "jj commit";
      jcm = "jj commit -m";
      jde = "jj desc";
      jdf = "jj diff";
      jdfd = "jj diff --tool delta";
      jdm = "jj desc -m";
      jgf = "jj git fetch";
      jfa = "jj git fetch --all-remotes";
      jgp = "jj git push";
      jl = "jj log";
      jlr = "jj log --reversed --no-pager";
      jn = "jj new";
      jnm = "jj new main";
      job = "jj obslog";
      jop = "jj op";
      jopl = "jj op list";
      jr = "jj rebase";
      jsq = "jj squash";
      jst = "jj status";

      rcd = "cd $(git rev-parse --show-toplevel)";

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
        name = "nix-zsh-completions";
        file = "nix-zsh-completions.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "spwhitt";
          repo = "nix-zsh-completions";
          rev = "468d8cf752a62b877eba1a196fbbebb4ce4ebb6f";
          sha256 = "16r0l7c1jp492977p8k6fcw2jgp6r43r85p6n3n1a53ym7kjhs2d";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
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
