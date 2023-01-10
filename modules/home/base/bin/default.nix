{
  lib,
  config,
  ...
}:
with lib; {
  options.base.user-bin.enable = mkEnableOption "user-bin";

  config = mkIf config.base.user-bin.enable {
    home.file = {
      "bin/in-each-dir" = {
        source = ./in-each-dir;
        executable = true;
      };

      "bin/dotbin" = {
        source = ./dotbin;
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
  };
}
