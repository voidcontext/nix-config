{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "cocogitto-dev";
  version = "5.3.1-dev";
  src = pkgs.fetchFromGitHub {
    owner = "oknozor";
    repo = "cocogitto";
    rev = "4a09837244e070ff6168cd247ed5621b41f4264e";
    sha256 = "sha256-NF7K4DYUrW2YXD57YImO4a9y2Ucyb8vKP5NlXC+ygsI=";
  };

  cargoHash = "sha256-s60mN5c3jmYb7MJonA5Ov79yrkGEpVqtNygXJharMjI=";

  # Test depend on git configuration that would likely exist in a normal user environment
  # and might be failing to create the test repository it works in.
  doCheck = false;

  nativeBuildInputs = [pkgs.installShellFiles];

  buildInputs = [pkgs.libgit2] ++ pkgs.lib.optional pkgs.stdenv.isDarwin pkgs.darwin.apple_sdk.frameworks.Security;

  postInstall = ''
    installShellCompletion --cmd cog \
      --bash <($out/bin/cog generate-completions bash) \
      --fish <($out/bin/cog generate-completions fish) \
      --zsh  <($out/bin/cog generate-completions zsh)
  '';

  # meta = with lib; {
  #   description = "A set of cli tools for the conventional commit and semver specifications";
  #   homepage = "https://github.com/oknozor/cocogitto";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [travisdavis-ops];
  # };
}
