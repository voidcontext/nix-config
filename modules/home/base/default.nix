{
  lib,
  config,
  systemConfig,
  pkgs,
  ...
}:
with lib; let
  cfg = config.base;
  update-symlinks = let
    updateCommands = lists.foldl (a: b: ''
      ${a}
      ${b}
    '') "" (attrsets.mapAttrsToList (name: value: "update_symlink ${name} ${value}") cfg.darwin_symlink);
  in
    pkgs.writeShellScriptBin "update-symlinks" ''
      function update_symlink () {
        _symlink=$1
        _expected_path=$2
        _current_path=$(realpath $_symlink)
        if [ "$_expected_path" != "$_current_path" ]; then
          rm $_symlink 2>/dev/null
          ln -s $_expected_path $_symlink
        fi
      }
      ${updateCommands}
    '';
  #  batr = pkgs.writeShellScriptBin "batr" ''
  #    ${pkgs.bat}/bin/bat ''$(${pkgs.coreutils}/bin/realpath ''$(${pkgs.which}/bin/which $1))
  # '';
in {
  imports = [
    ./bin
    ./git
    ./helix.nix
    ./starship.nix
    ./zsh.nix
  ];

  options = {
    base.gpg-ssh.enable = mkEnableOption "gpg-ssh";
    base.yubikey-tools.enable = mkEnableOption "yubikey-tools";
    base.darwin_symlinks = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
  };

  config = mkMerge [
    # Always applied
    {
      home.packages = optional pkgs.stdenv.isDarwin update-symlinks;

      # home.file.".gnupg/gpg-agent.conf".text = ''
      #   enable-ssh-support
      # '';

      programs.gpg.enable = true;
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = cfg.gpg-ssh.enable;
      services.gpg-agent.pinentryFlavor = "curses";
      programs.zsh.initExtra = ''
        export GPG_TTY=$(tty)
      '';

      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
        secureSocket = false;
      };

      programs.direnv.enable = true;
      programs.direnv.enableZshIntegration = true;
      programs.direnv.nix-direnv.enable = true;
    }

    # Optionals
    (mkIf cfg.yubikey-tools.enable {
      home.packages = [
        pkgs.yubikey-manager
      ];
    })
  ];
}
