{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.base;
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
  };

  config = mkMerge [
    # Always applied
    {
      home.file.".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
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
