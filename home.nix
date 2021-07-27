{ config, pkgs, zshInit ? "", extraAliases ? {}, hdpi ? false, ... }:

with builtins;

let
  aliases = import ./aliases.nix;
  sources = import ./nix/sources.nix;

  lambda-mod-theme = (fetchurl {
    url = "https://raw.githubusercontent.com/halfo/lambda-mod-zsh-theme/master/lambda-mod.zsh-theme";
    sha256 = "1gqkvvhr2qjjjqv7hmxl0bk6dg18ywa7icwr6yzw8i6r7sj15fl9";
  });

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

  home.file.".zsh/custom/themes/lambda-mod.zsh-theme".source = lambda-mod-theme;

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
    prompt_nix_shell_setup

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
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.2.0";
          sha256 = "1gfyrgn23zpwv1vj37gf28hf5z0ka0w5qm6286a7qixwv7ijnrx9";
        };
      }

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
