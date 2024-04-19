{
  description = "A very basic flake";

  inputs = {
  };

  outputs = { self }: {
    hosts = {
      deneb = {};
      electra = {};
      Sagittarius-A = {};
      work = {};
    };
    secrets = import ./secrets.nix;
  };
}
