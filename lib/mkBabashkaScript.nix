{
  writeText,
  writeShellApplication,
  babashka,
  ...
}: {
  name,
  scriptFile,
  bbExtrArgs ? "",
  scriptExtraArgs ? "",
  runtimeInputs ? [],
}: let
  script =
    writeText
    (builtins.baseNameOf scriptFile)
    (builtins.readFile scriptFile);
in
  writeShellApplication {
    inherit name;
    runtimeInputs = [babashka] ++ runtimeInputs;
    text = ''
      bb ${bbExtrArgs} ${script} ${scriptExtraArgs} "$@"
    '';
  }
