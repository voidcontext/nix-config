{callPackage, ...}: {
  deploy = callPackage ./deploy.nix {};
  jj = callPackage ./jj.nix {};
  rebuild = callPackage ./rebuild.nix {};
  unlock-extras = callPackage ./unlock-extras.nix {};
}
