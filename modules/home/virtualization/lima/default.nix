{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
with lib; let
  cfg = config.virtualization.lima;
  lima = pkgsUnstable.lima;
  # lima = pkgsUnstable.lima.overrideAttrs (old: {
  #   version = "${old.version}-1";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "lima-vm";
  #     repo = old.pname;
  #     rev = "v${old.version}";
  #     sha256 = "sha256-g4FvkjBviI1m8zlc+GK/09dIqVkTQ2MqqK1Wkyu4qBc=";
  #   };
  # });
  docker = pkgs.docker-client;
  lima-docker = pkgs.writeShellScriptBin "lima-docker" ''
        cmd=$1

        case "$cmd" in
           "init")
             ${lima}/bin/limactl delete docker -f
             ${lima}/bin/limactl start ${lima}/share/doc/lima/examples/docker.yaml
             ;;
           "start")
             ${lima}/bin/limactl list 2>/dev/null | grep docker > /dev/null
             if [ "$?" != "0" ]; then
               echo "Couldn't find docker instance, run init"
               exit 1
             fi
             ${lima}/bin/limactl start docker
             ;;
           "stop")
             ${lima}/bin/limactl stop docker
             ;;
           "delete")
             ${lima}/bin/limactl delete docker -f
             ;;
           "context")
             ${docker}/bin/docker context create lima --docker "host=unix:///Users/gaborpihaj/.lima/docker/sock/docker.sock"
             ${docker}/bin/docker context use lima
             ;;
           *)
           cat << EOF
    Usage lima-docker command

    Available commands:
        init       Deletes any existing instance then starts a new with the docker config from examples
        start      Starts an instance with the docker config from examples
        stop       Stops the docker instance
        delete     Deletes the docker instance even if it's running
        context    Creates the lime docker context if it does't exist and sets it automatically
    EOF
        esac
  '';
in {
  options.virtualization.lima.enable = mkEnableOption "lima";

  config = mkIf cfg.enable {
    home.packages = [
      lima
      lima-docker
      docker
    ];

    programs.zsh.initExtraBeforeCompInit = ''
      eval "$(${lima}/bin/limactl completion zsh)"
    '';
  };
}
