{ pkgs, modulesPath, ... }:
{
  imports =  [
    # Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
