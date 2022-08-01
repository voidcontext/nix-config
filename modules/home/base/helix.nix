{helix, ... }:

 {
  # Helix

  programs.helix = {
    enable = true;
    package = helix.package;
    settings = {
      theme = "gruvbox";
    };
    languages = [
      {
        name = "scala";
        auto-format = false;
      }
      {
        name = "nix";
        auto-format = false;
      }
      {
        name = "rust";
        auto-format = false;
      }
    ];
  };
}
