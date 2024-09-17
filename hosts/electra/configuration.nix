{
  pkgs,
  lib,
  config-extras,
  ...
}: {
  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = [
    config-extras.hosts.electra
    ./ci.nix
    ./nextcloud.nix
    ./samba.nix
    ./seafile.nix
    ./wireguard.nix
    ./zigbee.nix
  ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # boot.loader.raspberryPi.enable = true;
  # boot.loader.raspberryPi.version = 4;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;
  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.tmp.useTmpfs = false;

  # !!! This is only for ARMv6 / ARMv7. Don't enable this on AArch64, cache.nixos.org works there.
  #nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  #nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  #boot.kernelParams = ["cma=32M"];

  boot.initrd.availableKernelModules = ["xhci_pci" "usb_storage"];

  # Required for the Wireless firmware (Rpi4)
  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "usb-storage.quirks=0480:a006:u,152d:0578:u"
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/bab2c768-6e36-43c4-8add-867fcd92a959";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3247-4D1D";
      fsType = "vfat";
    };

    "/Volumes/raid" = {
      device = "/dev/disk/by-uuid/c8ff3ec3-d05b-4364-a270-17063920d74f";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };

    "/Volumes/secondary" = {
      device = "/dev/disk/by-uuid/6f748b9d-a966-4dc7-9987-ceb26b277cae";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };

    "/Volumes/data" = {
      device = "/dev/disk/by-uuid/56b9fcd9-22a1-41c7-b605-4691c1a12958";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };
  };

  services.udisks2.enable = true;

  # !!! Adding a swap file is optional, but strongly recommended!
  # swapDevices = [{ device = "/dev/disk/by-partuuid/ffa8342f-03";}];
  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 4096;
  #   }
  # ];

  system.stateVersion = "22.11";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.trusted-users = ["root" "vdx" "remote-builder"];
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "kraz.vdx.hu";
      sshUser = "remote-builder";
      system = "x86_64-linux";
      sshKey = "/Users/vdx/.ssh/kraz-remote-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdaMmMwektSeHcwa0syZEZCZ042QlVDY2kyUng3RnpLTlh0MGx1K0JaTHggcm9vdEBoZXR6bmVyCg==%";
      maxJobs = 8;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
  ];

  # Login / ssh / security

  programs.ssh.extraConfig = ''
    IPQoS cs0 cs0
  '';

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # users

  users.mutableUsers = false;
  users.users = {
    pi = {
      isNormalUser = true;
      home = "/home/pi";
      extraGroups = ["wheel" "networkmanager"];
      openssh.authorizedKeys.keys = [config-extras.secrets.ssh.public-keys.gpg];
    };

    vdx = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [config-extras.secrets.ssh.public-keys.gpg];
    };

    git = {
      isNormalUser = true;
      description = "git user";
      createHome = true;
      home = "/Volumes/raid/git";
      shell = "${pkgs.git}/bin/git-shell";
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000612711012"];
    };
    remote-builder = {
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        config-extras.secrets.ssh.public-keys."gaborpihaj@Sagittarius-A.lan -> electra remote-build"
      ];
    };
  };

  home-manager.users.vdx = import ./home-vdx.nix;

  environment.systemPackages = [
    pkgs.arp-scan
    pkgs.bwm_ng
    pkgs.cryptsetup
    pkgs.dnsutils
    pkgs.git
    pkgs.gnupg
    pkgs.htop
    pkgs.iperf3
    pkgs.libraspberrypi
    pkgs.tmux
    pkgs.usbutils
    pkgs.hdparm
    pkgs.smartmontools
    pkgs.attic-client
  ];

  networking = {
    hostName = "electra";
    firewall = {
      allowPing = true;
      allowedTCPPorts = [80 443 53 5201]; # nginx nginx dns iperf
      allowedUDPPorts = [53 5201]; # dns iperf
    };
  };

  services.cron = {
    enable = true;
  };

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      # These 2 settings were meant to fix the following startup issue:
      # Dec 01 15:12:03 electra postgres[24612]: [24612] LOG:  all server processes terminated; reinitializing
      # Dec 01 15:12:05 electra postgres[26426]: [26426] LOG:  database system was interrupted; last known up at 2022-12-01 15:06:44 G>
      # Dec 01 15:12:07 electra postgres[26426]: [26426] LOG:  database system was not properly shut down; automatic recovery in progr>
      # Dec 01 15:12:07 electra postgres[26426]: [26426] LOG:  redo starts at 3/65A42760
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  invalid record length at 3/65D905F8: wanted 24, got 0
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  redo done at 3/65D90530
      # Dec 01 15:12:08 electra postgres[26426]: [26426] LOG:  last completed transaction was at log time 2022-12-01 15:11:48.611876+00
      # Dec 01 15:12:08 electra postgres[26426]: [26426] PANIC:  could not flush dirty data: Structure needs cleaning
      fsync = "off";
      data_sync_retry = true;
    };
    authentication = lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };

  services.dnsmasq.enable = true;
  services.dnsmasq.settings.server = ["192.168.24.1"];
  services.dnsmasq.settings.listen-address = "127.0.0.1,192.168.24.2";
  services.dnsmasq.settings.interface = "podman0,podman1,podman2,podman3";
}
