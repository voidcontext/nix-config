{
  pkgs,
  ...
}: {
  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";
  base.gpg-ssh.enable = true;

  home.stateVersion = "21.11";

  programs.zsh.initExtra = ''
    export XDG_DATA_HOME="$HOME/.local/share"
  '';

  # make gpg ssh work: https://github.com/nix-community/home-manager/issues/3263
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';
}
