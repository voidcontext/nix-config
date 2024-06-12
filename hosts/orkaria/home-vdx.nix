{
  pkgs,
  config,
  ...
}: let
  sshHostRoles = {
    trusted = {...}: {
      forwardAgent = true;
    };

    external = {...}: {
      port = 5422;
    };

    gpg = {
      userId,
      hostname,
      ...
    }: {
      inherit hostname;
      user = "vdx";
      forwardAgent = true;
      remoteForwards = [
        {
          bind = {address = "/run/user/${builtins.toString userId}/gnupg/S.gpg-agent";};
          host = {address = "${config.home.homeDirectory}/.gnupg/S.gpg-agent";};
        }
      ];
    };
  };

  configureSshHost = {roles, ...} @ args: (builtins.foldl' (acc: role: acc // (sshHostRoles.${role} args)) {} roles);
in {
  imports = [
    ../../extras/hosts/Sagittarius-A.nix
  ];
  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";

  base.gpg-ssh.enable = true;

  home.stateVersion = "23.11";

  programs.zsh.initExtra = ''
    export XDG_DATA_HOME="$HOME/.local/share"
  '';

  # make gpg ssh work: https://github.com/nix-community/home-manager/issues/3263
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';

  home.file.".profile".text = ''
    export SDL_GAMECONTROLLERCONFIG="030000fdaf1e00002400000010010000785536,ClockworkPI uConsole,platform:Linux,a:b1,b:b2,x:b0,y:b3,back:b8,start:b9,leftx:a0,lefty:a1,"
  '';

  home.packages = [
    pkgs.neofetch
    pkgs.keepassxc
    pkgs.neomutt
    pkgs.w3m

    # for secret-tool (to get pws from the keyring)
    pkgs.libsecret

    #gamepad debug
    pkgs.xorg.xev
    pkgs.wev
    pkgs.antimicrox
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "deneb.vdx.hu" = configureSshHost {roles = ["trusted" "external"];};
      "deneb.vdx.hu.gpg" = configureSshHost {
        roles = ["trusted" "external" "gpg"];
        hostname = "vdx.hu";
        userId = 1000;
      };

      "kraz.vdx.hu" = configureSshHost {roles = ["trusted" "external"];};

      "git.vdx.hu" = configureSshHost {roles = ["external"];};

      "electra.lan" = configureSshHost {roles = ["trusted"];};
      "electra.lan.gpg" = configureSshHost {
        roles = ["trusted" "gpg"];
        hostname = "electra.lan";
        userId = 1004;
      };

      "albeiro.lan" = configureSshHost {roles = ["trusted"];};
    };
  };
}
