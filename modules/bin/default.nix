{pkgs, ...}:

{
  home.file = {
    "bin/in-each-dir" = {
      source = ./in-each-dir;
      executable = true;
    };

    "bin/rnsh" = {
      source = ./rnsh;
      executable = true;
    };

    "bin/ws" = {
      source = ./ws;
      executable = true;
    };
  };
}
