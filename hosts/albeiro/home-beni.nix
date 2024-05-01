{pkgs, ...}: {
  home.stateVersion = "23.11";

  home.packages = [
    pkgs.prismlauncher
  ];

  programs.zsh.initExtra = ''
    export XDG_DATA_HOME="$HOME/.local/share"
  '';
}
