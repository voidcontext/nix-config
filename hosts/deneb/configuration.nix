{ pkgs, modulesPath, ... }:
{
  imports =  [
    # Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  services.logind.extraConfig = ''
    # Otherwise emacs cannot be built
    RuntimeDirectorySize=500M
  '';


  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
