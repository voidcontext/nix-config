{ pkgs, jdk }:

{
  programs.zsh.initExtra = ''
    export JAVA_HOME="${jdk.home}"
  '';

  home.file.".emacs.d/init.el".text = ''
    (setenv "JAVA_HOME" "${jdk.home}")
  '';

  home.packages = [
    jdk
    pkgs.visualvm
  ];
}
