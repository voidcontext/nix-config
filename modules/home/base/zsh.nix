{ systemConfig, localLib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    envExtra = ''
      export NIX_IGNORE_SYMLINK_STORE=1
      export HM_ZSH_ENV=loaded
    '';

    initExtraBeforeCompInit = ''
      ZSH_THEME="simple"

      if [ "$INSIDE_EMACS" != "vterm" ]; then
          eval "$(starship init zsh)"
      fi

      if [ "HM_ZSH_ENV" != "loaded" ]; then
        source $HOME/.zshenv
      fi
    '';

    initExtra = ''
      PATH=$HOME/bin:$PATH:/usr/local/bin

      # [[ $TMUX != "" ]] && export TERM="screen-256color"
    '';

    shellAliases =
      let
        configInputs = "--inputs-from ${systemConfig.base.nixConfigFlakeDir}";
      in {
        ls = "exa";
        la = "exa -la";
        df = "duf";
        du = "dunst";
        h = "hx";

        e = "emacs -nw";
        ec = "emacsclient -nw -a= -s default";
        reload-zsh = "source ~/.zshrc";
        nsh = "nix-shell";

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

        rcd = "cd $(git rev-parse --show-toplevel)";

        dk = "docker";
        dkps = "docker ps";
        dkrma = "docker rm -f $(docker ps -a -q)";

        dkc = "docker compose";
        dkce = "docker compose exec";
        dkcu = "docker compose up -d";
        dkcl = "docker compose logs";
        dkcr = "docker compose stop && docker compose rm -f && docker compose up";

        nsp = "nix search ${configInputs} nixpkgs";
        nsu = "nix search ${configInputs} nixpkgs-unstable";
        nr = "nix run ${configInputs}";
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
      plugins = [
        "git"
        "z"
      ];
    };
  };
}
