{ helix, ... }:

{
  # Helix

  programs.helix = {
    enable = true;
    package = helix.package;
    settings = {
      theme = "gruvbox";
      # editor.whitespace.render = "all";
      editor.whitespace.render.space = "all";
      editor.whitespace.render.tab = "all";
      editor.whitespace.render.newline = "none";
      editor.indent-guides.render = true;
      editor.indent-guides.character = "╎";
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
