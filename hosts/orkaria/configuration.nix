{
  pkgs,
  config-extras,
  ...
}: {
  imports = [
    ./wireguard.nix
  ];

  boot.kernelParams = [
    "snd_bcm2835.enable_compat_alsa=0"
    "snd_bcm2835.enable_headphones=1"
    "snd_bcm2835.enable_hdmi=1"
  ];

  base.headless = false;
  base.font.family = "Iosevka";

  system.stateVersion = "23.11";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";
  # users.mutableUsers = false;
  users.users = {
    vdx = {
      isNormalUser = true;
      hashedPassword = config-extras.secrets.hosts.orkaria.passwords.vdx;
      extraGroups = ["wheel" "networkmanager" "video" "audio"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [config-extras.secrets.ssh.public-keys.gpg];
    };
    devuser = {
      isNormalUser = true;
      hashedPassword = config-extras.secrets.hosts.orkaria.passwords.nixos;
      extraGroups = ["wheel" "networkmanager" "video" "audio"];
      shell = pkgs.zsh;
    };
  };

  home-manager.users.vdx = import ./home-vdx.nix;

  networking.hostName = "orkaria";
  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  # services.xserver.desktopManager.cinnamon.enable = true;

  services.flatpak.enable = true;

  security.sudo.enable = true;
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    dosbox
    unzip
    pciutils
    alsa-tools
    lshw
    wirelesstools
    smplayer
    vlc
    (retroarch.override {
      cores = with libretro; [
        mesen
        snes9x
      ];
    })
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.trusted-users = ["root" "vdx"];

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "kraz.vdx.hu";
      sshUser = "remote-builder";
      system = "x86_64-linux";
      sshKey = "/home/vdx/.ssh/kraz-remote-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUdaMmMwektSeHcwa0syZEZCZ042QlVDY2kyUng3RnpLTlh0MGx1K0JaTHggcm9vdEBoZXR6bmVyCg==%";
      maxJobs = 8;
      supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
      protocol = "ssh";
    }
  ];
}
