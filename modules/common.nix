{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.ag
    pkgs.bashInteractive
    pkgs.bat
    pkgs.bwm_ng
    pkgs.coreutils
    pkgs.delta
    pkgs.gnugrep
    pkgs.gnupg
    pkgs.gnused
    pkgs.htop
    pkgs.jq
    pkgs.mc
    pkgs.mtr
    pkgs.niv
    pkgs.nixpkgs-fmt
    pkgs.nix-prefetch-git
    pkgs.neofetch
    pkgs.nmap
    pkgs.pstree
    pkgs.pwgen
    pkgs.telnet
    pkgs.tree
    pkgs.watch
    pkgs.wget
    pkgs.yubikey-manager
  ];

  home.file.".gnupg/gpg-agent.conf".text = ''
    enable-ssh-support
  '';

  programs.zsh = {
    enable = true;

    envExtra = ''
      export NIX_IGNORE_SYMLINK_STORE=1
      export HM_ZSH_ENV=loaded

      if [ "$IN_NIX_SHELL" = "" ] && [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
        . $HOME/.nix-profile/etc/profile.d/nix.sh
      fi
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

      [[ $TMUX != "" ]] && export TERM="screen-256color"

      export JAVA_HOME=$(readlink -f $(which java) | xargs dirname | xargs dirname)
    '';

    shellAliases = {
      e = "emacs -nw";
      ec = "emacsclient -nw -a= -s default";
      reload-zsh = "source ~/.zshrc";
      nsh = "nix-shell";

      enable-gpg-ssh = "export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent";
      learn-gpg-cardno = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';

      clean-metals = "rm -rf .bsp .metals .bloop project/metals.sbt project/.bloop";

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
    };

    sessionVariables = {
      EDITOR = "emacs -nw";
      PAGER = "less -R";
      PSQL_EDITOR = "emacsclient -nw -a= -s psql";
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

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = true;

      aws = {
        symbol = "  ";
      };

      character = {
        # success_symbol = "[λ](bold green)";
        error_symbol = "[✗](bold red)";
      };

      #     conda = {
      #       symbol = " ";
      #     };

      #     dart = {
      #       symbol = " ";
      #     };

      directory = {
        style = "bright-yellow";
        # read_only = " ";
      };

      docker_context = {
        # disabled = true;
        # symbol = " ";
      };

      #     elixir = {
      #       symbol = " ";
      #     };

      #     elm = {
      #       symbol = " ";
      #     };

      git_branch = {
        symbol = " ";
        style = "bold blue";
      };

      git_metrics = {
        disabled = false;
        added_style = "italic green";
        deleted_style = "italic red";
      };

      git_status = {
        style = "purple";
      };

      #     golang = {
      #       symbol = " ";
      #     };

      #     hg_branch = {
      #       symbol = " ";
      #     };

      #     java = {
      #       symbol = " ";
      #     };

      #     julia = {
      #       symbol = " ";
      #     };

      #     memory_usage = {
      #       symbol = " ";
      #     };

      #     nim = {
      #       symbol = " ";
      #     };

      nix_shell = {
        # symbol = " ";
        format = "via [$symbol(\($name\))]($style) ";
      };

      #     package = {
      #       symbol = " ";
      #     };

      #     perl = {
      #       symbol = " ";
      #     };

      #     php = {
      #       symbol = " ";
      #     };

      #     python = {
      #       symbol = " ";
      #     };

      #     ruby = {
      #       symbol = " ";
      #     };

      #     rust = {
      #       symbol = " ";
      #     };

      scala = {
        symbol = " ";
      };

      #     shlvl = {
      #       symbol = " ";
      #     };

      #     swift = {
      #       symbol = "ﯣ ";
      #     };
    };
  };


  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    secureSocket = false;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
