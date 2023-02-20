let
  mkHostnameExpr = pkgs: ''${pkgs.inetutils}/bin/hostname | ${pkgs.gnused}/bin/sed 's/\.\(local\|lan\)//' '';

  mkRebuildInitVars = pkgs: ''
    cmd=$1
    host=$2

    if [ -z "$cmd" ]; then
      echo "Command is required"
      exit 1
    fi

    if [ -z "$host" ]; then
      host=$(${mkHostnameExpr pkgs})
    fi
  '';
in {
  mkRebuildDarwin = pkgs:
    pkgs.writeShellScriptBin "rebuild" ''
      ${mkRebuildInitVars pkgs}
      TERM=kitty
      nix build ./#darwinConfigurations.$host.system --extra-experimental-features nix-command --extra-experimental-features flakes --show-trace && \
        ./result/sw/bin/darwin-rebuild $cmd --flake .#$host
      update-symlinks
    '';

  mkRebuildNixos = pkgs:
    pkgs.writeShellScriptBin "rebuild" ''
      ${mkRebuildInitVars pkgs}

      sudo nixos-rebuild $cmd --flake .#$host --show-trace
    '';

  # idea from: https://ayats.org/blog/channels-to-flakes
  modules.nixpkgs-pin.system = nixpkgs: nixpkgs-unstable: [
    # pin <nixpkgs> and <nixpkgs-unstable>
    {
      environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
      environment.etc."nix/inputs/nixpkgs-unstable".source = nixpkgs.outPath;
      nix.nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs" "nixpkgs-unstable=/etc/nix/inputs/nixpkgs-unstable"];
    }
    # pin nixpkgs and nixpkgs-unstable in registry
    {
      nix.registry.nixpkgs.flake = nixpkgs;
      nix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;
    }
  ];

  modules.nixpkgs-pin.home-manager = nixpkgs: nixpkgs-unstable: [
    # pin <nixpkgs> and <nixpkgs-unstable>
    (args: {
      xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;
      xdg.configFile."nix/inputs/nixpkgs-unstable".source = nixpkgs-unstable.outPath;
      home.sessionVariables.NIX_PATH =
        "nixpkgs=${args.config.xdg.configHome}/nix/inputs/nixpkgs:"
        + "nixpkgs-unstable=${args.config.xdg.configHome}/nix/inputs/nixpkgs-unstable"
        + "$\{NIX_PATH:+:$NIX_PATH}";
    })
    # pin nixpkgs and nixpkgs-unstable in registry
    {
      nix.registry.nixpkgs.flake = nixpkgs;
      nix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;
    }
  ];

  optionalStr = cond: str:
    if cond
    then str
    else "";
}
