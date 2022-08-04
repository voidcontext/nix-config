{ helix, ... }:

{
  # Helix
  
  home.file."workspace/.ignore".text = ''
  .bloop
  .bsp
  .direnv
  .idea
  .nix
  .metals

  node_modules
  target
  '';

  programs.helix = {
    enable = true;
    package = helix.package;
    settings = {
      theme = "gruvbox";
      editor.whitespace.render = "all";
      # editor.whitespace.render.space = "all";
      # editor.whitespace.render.tab = "all";
      # editor.whitespace.render.newline = "none";
      editor.indent-guides.render = true;
      # editor.indent-guides.character = "╎";
      editor.indent-guides.character = "|";
      editor.file-picker.hidden = false;
      editor.file-picker.git-ignore   = false;
      keys.insert.j = { k = "normal_mode"; }; # Maps `jk` to exit insert mode
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
