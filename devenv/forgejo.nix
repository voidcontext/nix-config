{
  lib,
  stdenv,
  mkShell,
  darwin,
  git-lfs,
  unstable,
}:
mkShell {
  packages =
    [
      git-lfs
      unstable.mockgen
    ]
    ++ (lib.lists.optionals stdenv.isDarwin [
      darwin.apple_sdk_11_0.Libsystem
      darwin.apple_sdk_11_0.frameworks.Security
    ]);
}
