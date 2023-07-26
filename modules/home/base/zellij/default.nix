{pkgs, ...}: let
  package = pkgs.unstable.zellij;
  src = pkgs.fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    rev = "v${package.version}";
    sha256 = "0mvkx5d69v4046bi9jr35rd5f0kz4prf0g7ja9xyh1xllpg8giv1";
  };
in {
  xdg.configFile.".config/zellij/themes" = {
    recursive = true;
    source = "${src}/zellij-utils/assets/themes";
  };

  xdg.configFile."zellij/layouts/rust.kdl".source = ./layouts/rust.kdl;
  xdg.configFile."zellij/layouts/rust-wasm-webapp.kdl".source = ./layouts/rust-wasm-webapp.kdl;
  xdg.configFile."zellij/layouts/scala.kdl".source = ./layouts/scala.kdl;

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  programs.zellij = {
    enable = true;
    inherit package;
  };
}
