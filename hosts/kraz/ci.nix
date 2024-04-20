{
  pkgs,
  config-extras,
  ...
}: let
  woodpeckerGRPCPort = 8001;
in {
  virtualisation.docker.enable = true;

  services.woodpecker-agents.agents.docker = {
    enable = true;
    package = pkgs.unstable.woodpecker-agent;
    environment = {
      DOCKER_HOST = "unix:///var/run/docker.sock";
      WOODPECKER_BACKEND = "docker";
      WOODPECKER_SERVER = "10.24.0.1:${builtins.toString woodpeckerGRPCPort}";
      WOODPECKER_AGENT_SECRET = config-extras.secrets.hosts.kraz.woodpecker.agent.secret;
      WOODPECKER_MAX_WORKFLOWS = "2";
    };
    extraGroups = [
      "docker"
    ];
  };

  environment.systemPackages = [
  ];
}
