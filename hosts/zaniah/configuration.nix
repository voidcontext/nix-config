{
  pkgs,
  secrets,
  ...
}: {
  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;
  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.tmp.useTmpfs = true;

  boot.initrd.availableKernelModules = [];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Required for the Wireless firmware (Rpi4)
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = pkgs.lib.mkDefault true;
  # networking.interfaces.enu1u1u1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = pkgs.lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = pkgs.lib.mkDefault "ondemand";

  nix = {
    package = pkgs.unstable.nix;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "23.05";

  services.openssh.enable = true;
  # services.openssh.settings.PasswordAuthentication = false;

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  users.mutableUsers = false;
  users.users = {
    pi = {
      isNormalUser = true;
      home = "/home/pi";
      extraGroups = ["wheel" "networkmanager"];
      openssh.authorizedKeys.keys = [secrets.ssh.public-keys.gpg];
    };

    vdx = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [secrets.ssh.public-keys.gpg];
    };
  };

  home-manager.users.vdx = import ./home-vdx.nix;

  environment.systemPackages = [
    pkgs.arp-scan
    pkgs.bwm_ng
    pkgs.dnsutils
    pkgs.git
    pkgs.gnupg
    pkgs.htop
    pkgs.iperf3
    pkgs.libraspberrypi
    pkgs.tmux
  ];

  networking = {
    hostName = "zaniah";
    firewall = {
      allowPing = true;
      allowedTCPPorts = []; #
      allowedUDPPorts = []; #
    };
  };
}
