{
  mkShell,
  darwin,
  git-lfs,
  unstable,
}:   mkShell {
    packages = [
      darwin.apple_sdk_11_0.Libsystem
      darwin.apple_sdk_11_0.frameworks.Security
      git-lfs
      unstable.mockgen
    ];
  }
