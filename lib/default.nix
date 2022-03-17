{
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
    else  "";
}
