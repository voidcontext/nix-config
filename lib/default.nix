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
      nix build ./#darwinConfigurations.$host.system --show-trace && \
        ./result/sw/bin/darwin-rebuild $cmd --flake .#$host
      update-symlinks
    '';

  mkRebuildNixos = pkgs:
    pkgs.writeShellScriptBin "rebuild" ''
      ${mkRebuildInitVars pkgs}

      sudo nixos-rebuild $cmd --flake .#$host --show-trace
    '';

  optionalStr = cond: str:
    if cond
    then str
    else "";
}
