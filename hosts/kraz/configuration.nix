{
  config,
  pkgs,
  secrets,
  ...
}: {
  base.font.enable = false;
  base.headless = true;

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./attic.nix
    ./ci.nix
    ./monitoring.nix
    ./wireguard.nix
  ];

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = ["/dev/sda" "/dev/sdb"];
  };

  networking.hostName = "kraz";

  # The mdadm RAID1s were created with 'mdadm --create ... --homehost=hetzner',
  # but the hostname for each machine may be different, and mdadm's HOMEHOST
  # setting defaults to '<system>' (using the system hostname).
  # This results mdadm considering such disks as "foreign" as opposed to
  # "local", and showing them as e.g. '/dev/md/hetzner:root0'
  # instead of '/dev/md/root0'.
  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines, so we tell mdadm to
  # ignore the homehost entirely.
  environment.etc."mdadm.conf".text = ''
    HOMEHOST <ignore>
  '';
  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.mdadmConf = ''
    HOMEHOST <ignore>
  '';

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."enp0s31f6".ipv4.addresses = [
    {
      address = "178.63.71.182";
      # FIXME: The prefix length is commonly, but not always, 24.
      # You should check what the prefix length is for your server
      # by inspecting the netmask in the "IPs" tab of the Hetzner UI.
      # For example, a netmask of 255.255.255.0 means prefix length 24
      # (24 leading 1s), and 255.255.255.192 means prefix length 26
      # (26 leading 1s).
      prefixLength = 24;
    }
  ];
  networking.interfaces."enp0s31f6".ipv6.addresses = [
    {
      address = "2a01:4f8:121:2274::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "178.63.71.129";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp0s31f6";
  };
  networking.nameservers = ["8.8.8.8"];

  # Login / ssh / security
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.ports = [5422];
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [secrets.ssh.public-keys.gpg];
  };

  users.users.remote-builder = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      secrets.ssh.public-keys."gaborpihaj@Sagittarius-A.lan -> kraz remote-build"
    ];
  };
  # Home manager

  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    hdpi = false;
    fontFamily = "nonexistent";
    nixConfigFlakeDir = "/opt/nix-config";
  };
  nix.package = pkgs.unstable.nix;
  nix.settings.trusted-users = ["root" "vdx" "remote-builder"];

  # Nginx

  security.acme.defaults.email = "admin+acme@vdx.hu";
  security.acme.acceptTerms = true;
  # services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  networking.firewall.allowedTCPPorts = [
    # nginx
    80
    443
    # minecraft servers on k3s
    32101 # mountain village
  ];
  networking.firewall.allowedUDPPorts = [
    # minecraft servers on k3s
    32101 # mountain village
  ];

  # k3s
  services.k3s.enable = true;
  services.k3s.package = pkgs.unstable.k3s_1_29;
  services.k3s.role = "server";
  environment.systemPackages = [pkgs.k3s];
  networking.firewall.interfaces."wg0".allowedTCPPorts = [
    6443
  ];
  networking.firewall.trustedInterfaces = ["cni+"];

  services.nginx.virtualHosts."staging.gaborpihaj.com" = {
    enableACME = true;
    forceSSL = true;
    locations."^~ /.well-known/acme-challenge" = {
      proxyPass = "http://localhost:8080";
      extraConfig = ''
        auth_basic off;
      '';
    };
    locations."/" = {
      proxyPass = "http://localhost:8443";
      basicAuthFile = "/opt/secrets/nginx/staging.gaborpihaj.com.htpasswd";
    };
  };
  services.nginx.virtualHosts."gaborpihaj.com" = {
    enableACME = false;
    forceSSL = true;
    sslCertificate = "/opt/secrets/nginx/gaborpihaj.com/fullchain.pem";
    sslCertificateKey = "/opt/secrets/nginx/gaborpihaj.com/key.pem";
    sslTrustedCertificate = "/opt/secrets/nginx/gaborpihaj.com/chain.pem";
    locations."/" = {
      proxyPass = "http://localhost:8443";
    };
  };
  services.xinetd.enable = true;
  services.xinetd.services = [
    {
      name = "svn";
      unlisted = true;
      port = 32101;
      server = "/usr/bin/env"; # not used if "redirect" is specified, but required by Nixos, *and* must be executable
      extraConfig = "redirect = 10.43.16.47 32101";
    }
  ];

  # FIXME
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05"; # Did you read the comment?
}
