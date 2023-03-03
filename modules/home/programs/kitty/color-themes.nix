{inputs, ...}: {
  gruvbox.dark.hard = builtins.readFile (inputs.kitty-gruvbox-themes + "/gruvbox_dark_hard.conf");
  gruvbox.dark.medium = builtins.readFile (inputs.kitty-gruvbox-themes + "/gruvbox_dark.conf");
  gruvbox.dark.soft = builtins.readFile (inputs.kitty-gruvbox-themes + "/gruvbox_dark_soft.conf");

  everforest.dark.hard = builtins.readFile (inputs.kitty-everforest-themes + "/themes/everforest_dark_hard.conf");
  everforest.dark.medium = builtins.readFile (inputs.kitty-everforest-themes + "/themes/everforest_dark_medium.conf");
  everforest.dark.soft = builtins.readFile (inputs.kitty-everforest-themes + "/themes/everforest_dark_soft.conf");
}
