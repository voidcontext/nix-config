{
  pkgs,
  modulesPath,
  home-manager,
  secrets,
  ...
}: {
  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = [
    # DO NOT REMOVE THIS! Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")

    # Additional imports
    ./ci.nix
    ./monitoring.nix
    ./wireguard.nix
  ];

  # Login / ssh / security

  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.ports = [5422];
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # security.acme.email = "admin+acme@gaborpihaj.com";

  networking.firewall.allowedTCPPorts = [443];
  networking.hostName = "elnath";

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [secrets.ssh.public-keys.gpg];
  };

  # Home manager

  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    hdpi = false;
    fontFamily = "nonexistent";
    nixConfigFlakeDir = "/opt/nix-config";
  };

  # Build configuration

  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  nix.package = pkgs.unstable.nix;
  nix.settings.trusted-substituters = ["file:///var/lib/woodpecker-agent/nix-store"];

  system.stateVersion = "22.11";
}
