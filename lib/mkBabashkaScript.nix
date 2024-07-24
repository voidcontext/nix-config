{
  writeTextFile,
  writeShellApplication,
  babashka,
  cljfmt,
  ...
}: {
  name,
  scriptFile,
  bbExtrArgs ? "",
  scriptExtraArgs ? "",
  runtimeInputs ? [],
}: let
  script = writeTextFile {
    name = builtins.baseNameOf scriptFile;
    text = builtins.readFile scriptFile;

    checkPhase = ''
      ${cljfmt}/bin/cljfmt check $target
    '';
  };
in
  writeShellApplication {
    inherit name;
    runtimeInputs = [babashka] ++ runtimeInputs;
    text = ''
      bb ${bbExtrArgs} ${script} ${scriptExtraArgs} "$@"
    '';
  }
