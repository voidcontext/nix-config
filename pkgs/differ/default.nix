{
  mkBabashkaScript,
  delta,
  ...
}:
mkBabashkaScript {
  name = "differ";
  runtimeInputs = [delta];
  scriptFile = ./differ.clj;
}
