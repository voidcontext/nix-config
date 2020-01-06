{config, pkgs, ...}:

let
  # Extra zsh config to enable sdkman
  zshInit = ''
  function wrap_for_alias {
    cmd=$1
    echo "Running: $cmd"
    eval $cmd
  }

  #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
  export SDKMAN_DIR="/Users/gaborpihaj/.sdkman"
  [[ -s "/Users/gaborpihaj/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/gaborpihaj/.sdkman/bin/sdkman-init.sh"
  '';

  workspace = "/Volumes/Workspace";
  extraAliases = {
    p = "cd " + workspace + "/private";
    d = "cd " + workspace + "/work";

    mcv = "wrap_for_alias './mvnw -s configuration/settings-noproxy.xml clean verify'";
    msbr = "SPRING_PROFILES_ACTIVE=local ./mvnw -s configuration/settings-noproxy.xml spring-boot:run";
  };
in
{
  imports = [
    (import ../../home.nix { inherit config; inherit pkgs; inherit zshInit; inherit extraAliases; })
  ];

  home.packages = [
    pkgs.joplin
#    pkgs.keepassxc
  ];
}
