{
  writeTextFile,
  writeShellApplication,
  unstable,
  # babashka,
  # cljfmt,
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
      ${unstable.cljfmt}/bin/cljfmt check $target
    '';
  };
in
  writeShellApplication {
    inherit name;
    runtimeInputs = [unstable.babashka] ++ runtimeInputs;
    text = ''
      bb ${bbExtrArgs} ${script} ${scriptExtraArgs} "$@"
    '';
  }
