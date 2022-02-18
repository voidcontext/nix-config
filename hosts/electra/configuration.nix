{ config, pkgs, lib, home-manager, nix-config-extras, ... }:

{
  imports = nix-config-extras.extraModules.electra ++
    [
      # Additional imports
      home-manager.nixosModules.home-manager
      ./samba.nix
    ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;
  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # !!! This is only for ARMv6 / ARMv7. Don't enable this on AArch64, cache.nixos.org works there.
  #nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  #nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  #boot.kernelParams = ["cma=32M"];

  # Required for the Wireless firmware (Rpi4)
  hardware.enableRedistributableFirmware = true;

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    # Prior to 19.09, the boot partition was hosted on the smaller first partition
    # Starting with 19.09, the /boot folder is on the main bigger partition.
    # The following is to be used only with older images.
    /*
      "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      };
    */
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    "/Volumes/raid" = {
      device = "/dev/disk/by-uuid/193611b5-ff82-4bda-8dcb-10a95ddc50a8";
      fsType = "ext4";
    };

    "/Volumes/data" = {
      device = "/dev/disk/by-uuid/56b9fcd9-22a1-41c7-b605-4691c1a12958";
      fsType = "ext4";
    };
  };

  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [{ device = "/swapfile"; size = 2048; }];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

# Login / ssh / security

  programs.ssh.extraConfig = ''
    IPQoS cs0 cs0
  '';

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

# users

  users.mutableUsers = false;
  users.users = {
    pi = {
      isNormalUser = true;
      home = "/home/pi";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000605439573"
      ];
    };

    vdx = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000605439573"
      ];
    };

    git = {
      isNormalUser = true;
      description = "git user";
      createHome = true;
      home = "/Volumes/raid/git";
      shell = "${pkgs.git}/bin/git-shell";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000612711012" ];
    };
  };

  # Home manager

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    emacsGui = false;
    hdpi = false;
    nixConfigFlakeDir = "/opt/nix-config";
  };


  environment.systemPackages = [
    pkgs.arp-scan
    pkgs.bwm_ng
    pkgs.cryptsetup
    pkgs.dnsutils
    pkgs.emacs27-nox
    pkgs.git
    pkgs.htop
    pkgs.iperf3
    pkgs.tmux
    pkgs.gnupg

    # modern unix
    pkgs.bat
    pkgs.du-dust
    pkgs.duf
  ];

  networking = {
    hostName = "electra";
    firewall = {
      allowPing = true;
      allowedTCPPorts = [ 80 443 53 5201 ]; # nginx nginx dns iperf
      allowedUDPPorts = [ 53 5201 ]; # dns iperf
    };
  };

  services.openvpn.servers = {
    vdxHU = { config = '' config /etc/nixos/antares-vdxhu.ovpn ''; };
  };

  services.cron = {
    enable = true;
  };

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.vdx.hu";
    home = "/Volumes/raid/nextcloud";
    package = pkgs.nextcloud22;
    maxUploadSize = "20G";
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/Volumes/raid/config/nextcloud/.adminpassword";
      adminuser = "root";
      #      extraTrustedDomains = [ "nextcloud.electra0.lan" ];
    };
  };

  services.nginx.virtualHosts."nextcloud.vdx.hu" = {
    serverAliases = [ "netxcloud.vdx.hu" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    dataDir = "/Volumes/raid/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
    authentication = lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.bind = {
    enable = true;
    cacheNetworks = [ "127.0.0.0/24" "192.168.24.0/24" ];
    zones = [
      {
        name = "nextcloud.vdx.hu";
        master = true;
        file = "/etc/nixos/nextcloud.vdx.hu.zone";
        masters = [ ];
        slaves = [ ];
        extraConfig = "";
      }
      {
        name = "electra.lan";
        master = true;
        file = "/etc/nixos/electra.lan.zone";
        masters = [ ];
        slaves = [ ];
        extraConfig = "";
      }
    ];
    ipv4Only = true;
    extraConfig = ''
      logging {
        channel querylog {
          file "/var/log/named-querylog";
          severity debug 3;
        };

        category queries { querylog;};
      };
    '';
    extraOptions = ''
      allow-transfer {"none";};
      max-cache-size 50%;
    '';
  };
}
