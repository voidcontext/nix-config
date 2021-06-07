{ config, pkgs, zshInit ? "", extraAliases ? {}, hdpi ? false, ... }:

with builtins;

let
  aliases = import ./aliases.nix;
  sources = import ./nix/sources.nix;

  lambda-mod-theme = (fetchurl {
    url = "https://raw.githubusercontent.com/halfo/lambda-mod-zsh-theme/master/lambda-mod.zsh-theme";
    sha256 = "1gqkvvhr2qjjjqv7hmxl0bk6dg18ywa7icwr6yzw8i6r7sj15fl9";
  });

  zsh-plugins = {
    nix-shell = (fetchGit {
      url = "https://github.com/chisui/zsh-nix-shell.git";
      ref = "master";
      rev = "0f8b8c0d9d680d12c47e328c2a9e832d40ada1a2";
    });

    nix-zsh-completions = (fetchGit {
      url = "https://github.com/spwhitt/nix-zsh-completions.git";
      ref = "master";
      rev = "468d8cf752a62b877eba1a196fbbebb4ce4ebb6f";
    });

  };
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
    pkgs.coreutils
    pkgs.gnupg
    pkgs.gnused
    pkgs.htop
    pkgs.jq
    pkgs.mc
    pkgs.mtr
    pkgs.niv
    # pkgs.nix-direnv
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

  home.file.".zsh/custom/themes/lambda-mod.zsh-theme".source = lambda-mod-theme;
  home.file.".zsh/custom/plugins/nix-shell".source = zsh-plugins.nix-shell;
  home.file.".zsh/custom/plugins/nix-zsh-completions".source = zsh-plugins.nix-zsh-completions;

  # home.file.".config/direnv/direnvrc".text = ''
  # if [ -f ~/.nix-profile/share/nix-direnv/direnvrc ]; then
  #   source ~/.nix-profile/share/nix-direnv/direnvrc
  # fi
  # '';

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
    if [ -n "$INSIDE_EMACS" ] && [ "$INSIDE_EMACS" != "vterm" ]; then
      ZSH_THEME="simple"
    else
      ZSH_THEME="lambda-mod"
    fi

    if [ "HM_ZSH_ENV" != "loaded" ]; then
      source $HOME/.zshenv
    fi

    if [ -d ~/.itermocil ]; then
        compctl -g '~/.itermocil/*(:t:r)' itermocil
    fi
    '';

    initExtra = ''
    # prompt_nix_shell_setup

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

    oh-my-zsh = {
      enable = true;
#      theme = "lambda-mod";
      custom = "$HOME/.zsh/custom/";
      plugins = ["git" "z" "nix-zsh-completions" "nix-shell" ];
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
