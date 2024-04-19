{
  hosts = {
    deneb = import ./hosts/deneb.nix;
    electra = import ./hosts/electra.nix;
    # Sagittarius-A = import ./hosts/Sagittarius-A.nix;
    work = import ./hosts/work.nix;
  };
  secrets = import ./secrets.nix;
}
