{
  pkgs,
  inputs,
  lib,
  ...
}: let
  linuxSystem = "x86_64-linux";
  darwin-builder = inputs.nixpkgs.lib.nixosSystem {
    system = linuxSystem;
    modules = [
      "${inputs.nixpkgs}/nixos/modules/profiles/macos-builder.nix"
      {
        virtualisation.host.pkgs = pkgs;
        virtualisation.darwin-builder.hostPort = 33022;
        system.nixos.revision = lib.mkForce null;
      }
    ];
  };
in {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "linux-builder";
      sshUser = "builder";
      system = linuxSystem;
      sshKey = "/etc/nix/builder_ed25519";
      # publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
      maxJobs = 4;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
    {
      hostName = "electra.lan";
      sshUser = "vdx";
      system = "aarch64-linux";
      sshKey = "/Users/gaborpihaj/workspace/personal/nix-config/y";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtDM2s5K0Z1OXZtNFIvQUVnWVJQbFYzSFdXZERBdTBLd2s5TFJtdXV0YTMgcm9vdEBuaXhvcwo=";
      maxJobs = 4;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
  ];

  launchd.daemons.darwin-builder = {
    command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
      WorkingDirectory = "/etc/nix/";
    };
  };
}
