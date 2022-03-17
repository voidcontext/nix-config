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

in
{

  mkRebuildDarwin = pkgs: pkgs.writeShellScriptBin "rebuild" ''
    ${mkRebuildInitVars pkgs}

    nix build ./#darwinConfigurations.$host.system && ./result/sw/bin/darwin-rebuild $cmd --flake .#$host
  '';

  mkRebuildNixos = pkgs: pkgs.writeShellScriptBin "rebuild" ''
    ${mkRebuildInitVars pkgs}

    sudo nixos-rebuild $cmd --flake "/opt/nix-config#$host"
  '';



  mkSys = { system, nixpkgs, nixpkgs-unstable, overlays ? [ ] }:
    {
      inherit system;
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system overlays;
      };
    };

  optionalStr = cond: str:
    if cond then str
    else "";
}
