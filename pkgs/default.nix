{callPackage, ...}: {
  config-extras = callPackage ./config-extras.nix {};
  deploy = callPackage ./deploy.nix {};
  differ = callPackage ./differ {};
  gallery-manager = callPackage ./gallery-manager {};
  jj = callPackage ./jj.nix {};
  rebuild = callPackage ./rebuild {};
  tasker = callPackage ./tasker {};
}
