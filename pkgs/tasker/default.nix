{
  mkBabashkaScript,
  gum,
  ...
}:
mkBabashkaScript {
  name = "tasker";
  runtimeInputs = [gum];
  scriptFile = ./tasker.clj;
}
