{...}: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "kraz.vdx.hu";
      sshUser = "remote-builder";
      system = "x86_64-linux";
      sshKey = "/Users/gaborpihaj/.ssh/kraz-remote-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdaMmMwektSeHcwa0syZEZCZ042QlVDY2kyUng3RnpLTlh0MGx1K0JaTHggcm9vdEBoZXR6bmVyCg==%";
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
