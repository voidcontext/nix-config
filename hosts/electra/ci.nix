{
  pkgs,
  config-extras,
  ...
}: let
  woodpeckerGRPCPort = 8001;
in {
  # virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "devicemapper";

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.settings = {
    dns_enabled = true;
  };

  services.woodpecker-agents.agents.docker = {
    enable = true;
    package = pkgs.unstable.woodpecker-agent;
    environment = {
      DOCKER_HOST = "unix:///run/docker.sock";
      WOODPECKER_BACKEND = "docker";
      WOODPECKER_SERVER = "10.24.0.1:${builtins.toString woodpeckerGRPCPort}";
      WOODPECKER_AGENT_SECRET = config-extras.secrets.hosts.electra.woodpecker.agent.secret;
      WOODPECKER_HEALTHCHECK_ADDR = ":4000";
      WOODPECKER_MAX_WORKFLOWS = "1";
    };
    extraGroups = [
      "podman"
    ];
  };

  networking.firewall.interfaces."podman0".allowedUDPPorts = [53];
  networking.firewall.interfaces."podman0".allowedTCPPorts = [53];

  users.users.vdx.extraGroups = ["podman"];

  environment.systemPackages = [
    pkgs.docker-client
  ];
}
