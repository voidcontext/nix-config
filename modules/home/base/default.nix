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
    '') "" (attrsets.mapAttrsToList (name: value: "update_symlink ${name} ${value}") cfg.darwin_symlinks);
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
    ./zellij
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
      home.packages = [pkgs.findutils] ++ (optional pkgs.stdenv.isDarwin update-symlinks);

      programs.gpg.enable = true;
      programs.gpg.scdaemonSettings = {
        # On darwin ccid needs to be disabled (disable=true), on linux it needs to be enabled (disable=false) to make Yubikey work
        disable-ccid = pkgs.stdenv.isDarwin;
      };
      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
        secureSocket = false;
      };

      programs.direnv.enable = true;
      programs.direnv.enableZshIntegration = true;
      programs.direnv.nix-direnv.enable = true;
    }

    (mkIf pkgs.stdenv.isLinux {
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = cfg.gpg-ssh.enable;
      services.gpg-agent.pinentryFlavor = "curses";
      # programs.zsh.initExtra = ''
      #   export GPG_TTY=$(tty)
      # '';
    })

    (mkIf pkgs.stdenv.isDarwin {
      home.file.".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
      '';
    })

    (mkIf (pkgs.stdenv.isDarwin && cfg.gpg-ssh.enable) {
      programs.zsh.initExtra = ''
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) && gpgconf --launch gpg-agent
      '';
    })

    # Optionals
    (mkIf cfg.yubikey-tools.enable {
      home.packages = [
        pkgs.yubikey-manager
      ];
    })
  ];
}
