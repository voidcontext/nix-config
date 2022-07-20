{ lib, config, systemConfig, pkgs, ... }:

with lib;
let
  cfg = config.base;
  updateCommands = attrsets.mapAttrsToList (name: value: "update_symlink ${name} ${value}") cfg.darwin_symlinks;
  update-symlinks = pkgs.writeShellScriptBin "update-symlinks" ''
    function update_symlink () {
      _symlink=$1
      _expected_path=$2
      _current_path=$(realpath $_symlink)
      if [ "$_expected_path" != "$_current_path" ]; then
        rm $_symlink 2>/dev/null
        ln -s $_expected_path $_symlink
      fi
    }
    ${
      lists.foldl (a: b: ''
      ${a}
      ${b}
      '') "" updateCommands
    }
    '';
in
{
  imports = [
    ./bin
    ./emacs
    ./git
    ./starship.nix
    ./zsh.nix
  ];

  options = {
    base.zsh.gpg-ssh.enable = mkEnableOption "gpg-ssh";
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

      home.file.".gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      '';

      home.file.".gnupg/scdaemon.conf".text = ''
      disable-ccid
      '';

      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
        secureSocket = false;
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };

    }

    # Optionals
    (mkIf cfg.zsh.gpg-ssh.enable {

      programs.zsh.initExtra = ''
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent
      '';
    })
    (mkIf cfg.yubikey-tools.enable {
      home.packages = [
        pkgs.yubikey-manager
      ];
    })
  ];
}
