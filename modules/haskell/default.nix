{ pkgs, ... }:

{
  # emacs
  home.file.".emacs.d/init.el".text = (builtins.readFile ./init.el);

  programs.emacs.extraPackages = epkgs: with epkgs; [
    lsp-haskell
  ];
}
