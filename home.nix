{ config, pkgs, ... }:

with import <nixpkgs>;
with builtins;

let
  aliases = import ./aliases.nix;
  
  lambda-mod-theme = (fetchurl {
    url = "https://raw.githubusercontent.com/halfo/lambda-mod-zsh-theme/master/lambda-mod.zsh-theme";
    sha256 = "1azg02pfn25rs1km1l56xawcl1pa9m7c7km74sghb57dsbvvacrq";
  });

  zsh-plugins = {
    nix-shell = (fetchGit {
      url = "https://github.com/chisui/zsh-nix-shell.git";
      rev = "166c86c609a5398453f6386efd70c3cdb66b2058";
    });

    nix-zsh-completions = (fetchGit {
      url = "https://github.com/spwhitt/nix-zsh-completions.git";
      rev = "adbf7bf6dd01f2410700fa51cdb31346c8108318";
    });
    
  };
in
{
  home.packages = [
    pkgs.htop
  ];

  home.file.".zsh/custom/themes/lambda-mod.zsh-theme".source = lambda-mod-theme;
  home.file.".zsh/custom/plugins/nix-shell".source = zsh-plugins.nix-shell; 
  home.file.".zsh/custom/plugins/nix-zsh-completions".source = zsh-plugins.nix-zsh-completions; 

  programs.emacs.enable = true;

  programs.zsh = {
    enable = true;

    initExtra = ''
    . /home/nix-test/.nix-profile/etc/profile.d/nix.sh
    export NIX_PATH=/home/nix-test/.nix-defexpr/channels:/home/nix-test/.nix-defexpr/channels

    prompt_nix_shell_setup
    '';

    shellAliases = aliases;

    oh-my-zsh = {
      enable = true;
      theme = "lambda-mod";
      custom = "$HOME/.zsh/custom/";
      plugins = ["git" "z" "nix-zsh-completions" "nix-shell" ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Gabor Pihaj";
    userEmail = "gabor.pihaj@gmail.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
