{
  inputs,
  pkgs,
  ...
}: let
  secrets = import ./secrets.nix;
  woodpeckerGRPCPort = 8001;
  woodpeckerAgentSetup = pkgs.writeShellScriptBin "woodpecker-agent-setup" ''
    mkdir -p /var/lib/woodpecker-agent/nix-store/
  '';
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/continuous-integration/woodpecker/agents.nix"
    # "${inputs.nixpkgs-unstable}/nixos/modules/services/continuous-integration/woodpecker/server.nix"
  ];

  virtualisation.docker.enable = true;

  systemd.services.woodpecker-agent-setup = {
    description = "woodpecker agent setup";

    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";

      ExecStart = "${woodpeckerAgentSetup}/bin/woodpecker-agent-setup";

      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  services.woodpecker-agents.agents.docker = {
    enable = true;
    package = pkgs.unstable.woodpecker-agent;
    environment = {
      DOCKER_HOST = "unix:///var/run/docker.sock";
      WOODPECKER_BACKEND = "docker";
      WOODPECKER_SERVER = "10.131.0.2:${builtins.toString woodpeckerGRPCPort}";
      WOODPECKER_AGENT_SECRET = secrets.woodpecker.agent.secret;
    };
    extraGroups = [
      "docker"
    ];
  };

  environment.systemPackages = [
  ];
}
