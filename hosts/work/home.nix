{config, pkgs, ...}:

let
  # Extra zsh config to enable sdkman
  zshInit = ''
  export NIX_BUILD_SHELL=$(nix-build -A bashInteractive '<nixpkgs>')/bin/bash
  '';

  workspace = "/Volumes/workspace";
  extraAliases = {
    p = "cd " + workspace + "/personal";
    d = "cd " + workspace + "/work";
  };
in
{
  imports = [
    (import ../../home.nix { inherit config; inherit pkgs; inherit zshInit; inherit extraAliases; hdpi = true;})
  ];

  home.packages = [
    pkgs.joplin
    pkgs.keepassxc
    pkgs.postgresql_10
  ];
}
