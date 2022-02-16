{ modulesPath, ... }:
{
  imports =  [
    # Default configuration for DO droplet
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];
}
