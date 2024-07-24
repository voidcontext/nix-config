{
  mkBabashkaScript,
  findutils,
  exiftool,
  ...
}:
mkBabashkaScript {
  name = "gallery-manager";
  runtimeInputs = [findutils exiftool];
  scriptFile = ./gallery-manager.clj;
}
