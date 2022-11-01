{ pkgs, pkgsUnstable, modulesPath, home-manager, nix-config-extras, ... }:
{

  # Bespoke Options

  base.font.enable = false;
  base.headless = true;

  base.nixConfigFlakeDir = "/opt/nix-config";

  # Upstream options

  imports = nix-config-extras.extraModules.deneb ++
    [
      # DO NOT REMOVE THIS! Default configuration for DO droplet
      (modulesPath + "/virtualisation/digital-ocean-config.nix")

      # Additional imports
      ./blog.nix
      ./spellcasterhub.nix
    ];

  # Login / ssh / security

  services.openssh.passwordAuthentication = false;
  services.openssh.ports = [ 5422 ];
  services.openssh.extraConfig = ''
    # for gpg tunnel
    StreamLocalBindUnlink yes
  '';

  security.sudo.enable = true;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # security.acme.email = "admin+acme@gaborpihaj.com";

  networking.firewall.allowedTCPPorts = [ 443 ];

  # User Management

  users.mutableUsers = false;
  users.users.vdx = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDADgf8KaKWIqwJmQPhyLKLwfUplk6RDQ0j/SgcwuHlVj6WRVJJZbFEutnKn5gfZ75M2Wzmsrn7F1W1/CEvmGohE7bLz00ZpM38Hlw/1U2S7ABZ1GwistN42HBMy/jufme0vb4bzFKWH6sXsEnezg1zUPAJlIBA0OxVuKaTQAQOTIEi1ytVrq2wNa9Iiv+Bb6OeK/Vnt8HFOv1H3xmZNtn/N7X35kO5aCwaUlHPpr/7jxQf02fuNhnc0jU6VVygG7uwlfu3j/1lT7DDeIAEYbIeOXRg6Xn+HzDpHdv6FSipSwp499f8tC3TUZDdXT+iSAL9IOZuaujX0qME4bOJZOJuSGPckj9n97gbzoxFEzPsyAFRDgT7MRzQg4QW0fUj3/R9P/DqtxA8F/qfqOQ+Wy2AJ0M+eXrDuZoxZ4F6j4jKaxoUfylYWplILC9kxkk4q0enocOuzxGM6j9rVg9T1wG4/4auKSqENS5QXsvYAsu63RE4WwxAwxuSIymMwA0WhJ6PGgFzlFHluRP8NVlMeCuCZ+0eopH7hqvwZH4m9RmsnadMk0wkZ6ZjsJ0oeFjIxOysiaQbM9lbE0iuoRKRO4E2pfOXt+Nu94r6W8IUVkGYs7PdpsTntnv2pKh8P28/7uE09/U1DfgyYq8BZ+z9bb7GFwpfuZGCXAAvooZDY40b+Q== cardno:000605439573"
    ];
  };

  users.users.tun = {
    isNormalUser = true;
  };

  # Home manager

  home-manager.users.vdx = import ./home-vdx.nix;

  home-manager.extraSpecialArgs = {
    emacsGui = false;
    hdpi = false;
    fontFamily = "nonexistent";
    nixConfigFlakeDir = "/opt/nix-config";
  };

  # Build configuration

  services.logind.extraConfig = ''
    # Otherwise emacs cannot be built
    RuntimeDirectorySize=500M
  '';

  nix.package = pkgsUnstable.nix;
  nix.settings.substituters = [ "https://indieweb-tools.cachix.org" ];
  nix.settings.trusted-public-keys = [ "indieweb-tools.cachix.org-1:yPp4kg6bp8YLLEhuz/wRhEvPLuc3PJFZa5C8zEmw4es=" ];
}
