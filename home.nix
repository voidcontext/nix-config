{ config, pkgs, ... }:

with import <nixpkgs>;
with builtins;

let
  lambda-mod-theme = (fetchurl {
    url = "https://raw.githubusercontent.com/halfo/lambda-mod-zsh-theme/master/lambda-mod.zsh-theme";
    sha256 = "1azg02pfn25rs1km1l56xawcl1pa9m7c7km74sghb57dsbvvacrq";
  });
in
{
#  home.packages = [
#  ];

  home.file.".zsh/custom/themes/lambda-mod.zsh-theme".source = lambda-mod-theme;

  programs.emacs.enable = true;

  programs.zsh = {
    enable = true;

    profileExtra = ''
    . /home/nix-test/.nix-profile/etc/profile.d/nix.sh
    export NIX_PATH=/home/nix-test/.nix-defexpr/channels:/home/nix-test/.nix-defexpr/channels
    '';

    oh-my-zsh = {
      enable = true;
      theme = "lambda-mod";
      custom = "$HOME/.zsh/custom/";
      plugins = ["git" "z"];
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
