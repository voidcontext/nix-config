{
  inputs,
  self,
}: let
  inherit (inputs) deploy-rs;
in {
  electra = {
    sshUser = "vdx";
    sshOpts = ["-A"];
    hostname = "electra.lan";
    remoteBuild = true;

    profiles.system.user = "root";
    profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.electra;
  };

  deneb = {
    sshUser = "vdx";
    sshOpts = ["-A"];
    hostname = "deneb.vdx.hu";
    remoteBuild = true;
    fastConnection = false;

    profiles.system.user = "root";
    profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.deneb;
  };

  kraz = {
    sshUser = "vdx";
    sshOpts = ["-A" "-p5422"];
    hostname = "178.63.71.182";
    remoteBuild = true;
    fastConnection = false;

    profiles.system.user = "root";
    profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kraz;
  };

  albeiro = {
    sshUser = "vdx";
    sshOpts = ["-A"];
    hostname = "albeiro.lan";
    remoteBuild = true;
    fastConnection = false;

    profiles.system.user = "root";
    profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.albeiro;
  };

  orkaria = {
    sshUser = "vdx";
    sshOpts = ["-A"];
    hostname = "192.168.24.227";
    remoteBuild = false;
    fastConnection = false;

    profiles.system.user = "root";
    profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.orkaria;
  };
}
