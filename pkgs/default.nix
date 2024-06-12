{callPackage, ...}: {
  deploy = callPackage ./deploy.nix {};
  jj = callPackage ./jj.nix {};
  rebuild = callPackage ./rebuild {};
  config-extras = callPackage ./config-extras.nix {};
}
