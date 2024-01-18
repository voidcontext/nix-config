{...}: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "kraz.vdx.hu";
      sshUser = "remote-builder";
      system = "x86_64-linux";
      sshKey = "/Users/gaborpihaj/.ssh/kraz-remote-builer";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSURURW4rb05nNW9MYmNMRmdRZjFGSFNLdnQzVSs1UHp6VWwwN05CdzJDSFogcm9vdEBlbG=";
      maxJobs = 8;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
    {
      hostName = "electra.lan";
      sshUser = "remote-builder";
      system = "aarch64-linux";
      sshKey = "/Users/gaborpihaj/.ssh/electra-remote-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtDM2s5K0Z1OXZtNFIvQUVnWVJQbFYzSFdXZERBdTBLd2s5TFJtdXV0YTMgcm9vdEBuaXhvcwo=";
      maxJobs = 4;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
  ];
}
