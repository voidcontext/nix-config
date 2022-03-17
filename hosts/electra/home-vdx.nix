{ config, pkgs, ... }:

{

  base.zsh.gpg-ssh.enable = true;
  base.yubikey-tools.enable = false;

  base.git.enable = true;
  base.git.name = "Gabor Pihaj";
  base.git.email = "gabor.pihaj@gmail.com";
  base.git.sign = true;
  base.git.signing-key = "D67CE41772FAF6E369B74AAC369D85A32437F62D";

  development.clojure.enable = false;
  development.rust.enable = false;
  development.scala.enable = false;

}
