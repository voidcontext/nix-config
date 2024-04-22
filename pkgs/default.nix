{callPackage, ...}:

{
  rebuild = callPackage ./rebuild.nix {};
  jj = callPackage ./jj.nix {};
  deploy = callPackage ./deploy.nix {};
  unlock-extras = callPackage ./unlock-extras.nix {};
}
