{
  mkBabashkaScript,
  findutils,
  exiftool,
  rsync,
  kubectl,
  ...
}:
mkBabashkaScript {
  name = "gallery-manager";
  runtimeInputs = [findutils exiftool rsync kubectl];
  scriptFile = ./gallery-manager.clj;
}
