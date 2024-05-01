{callPackage, ...}: {
  deploy = callPackage ./deploy.nix {};
  jj = callPackage ./jj.nix {};
  rebuild = callPackage ./rebuild.nix {};
  config-extras = callPackage ./config-extras.nix {};
}
