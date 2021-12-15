{ config, pkgs, zshInit ? "", extraAliases ? {}, hdpi ? false, ... }:

with builtins;

let
  aliases = import ./aliases.nix;
  sources = import ./nix/sources.nix;

  jdk = (pkgs.callPackage ./modules/openjdk {});
in
{
  imports = [
    (import ./modules/adr-tools {inherit pkgs;})
    (import ./modules/emacs {inherit pkgs; inherit hdpi;})
    (import ./modules/scala {inherit pkgs; inherit jdk;})
    (import ./modules/clojure {inherit pkgs; inherit jdk;})
    (import ./modules/git {inherit pkgs; inherit config;})
    (import ./modules/bin {inherit pkgs; inherit config;})
  ];

  nixpkgs.overlays = [
    (import sources.emacs-overlay)
  ];

  home.packages = [
    pkgs.ag
    pkgs.bashInteractive
    pkgs.bwm_ng
    pkgs.coreutils
    pkgs.gnupg
    pkgs.gnused
    pkgs.htop
    pkgs.jq
    pkgs.mc
    pkgs.mtr
    pkgs.niv
    # pkgs.nix-direnv
    pkgs.nix-prefetch-git
    pkgs.neofetch
    pkgs.nmap
    pkgs.pstree
    pkgs.pwgen
    pkgs.telnet
    pkgs.thefuck
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

    if [ "$IN_NIX_SHELL" = "" ]; then
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

    if [ -d ~/.itermocil ]; then
        compctl -g '~/.itermocil/*(:t:r)' itermocil
    fi
    '';

    initExtra = ''
    PATH=$HOME/bin:$PATH:/usr/local/bin

    [[ $TMUX != "" ]] && export TERM="screen-256color"

    export JAVA_HOME=$(readlink -f $(which java) | xargs dirname | xargs dirname)

    eval $(thefuck --alias)
    '' + zshInit;

    shellAliases = aliases // extraAliases;

    sessionVariables = {
      EDITOR = "emacs -nw";
      PAGER = "less -R";
      PSQL_EDITOR="emacsclient -nw -a= -s psql";
    };

    plugins = [
      {
        name = "nix-zsh-completions";
        file = "nix-zsh-completions.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "spwhitt";
          repo = "nix-zsh-completion";
          rev = "468d8cf752a62b877eba1a196fbbebb4ce4ebb6f";
          sha256 = "16r0l7c1jp492977p8k6fcw2jgp6r43r85p6n3n1a53ym7kjhs2d";
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
