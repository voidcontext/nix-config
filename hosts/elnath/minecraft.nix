{pkgs, ...}: let
  serverPort = 36456;
  secrets = import ./secrets.nix;
in {
  services.minecraft-server = {
    enable = true;
    package = pkgs.unstable.minecraft-server.override {
      version = "1.20.4";
      url = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar";
      sha1 = "9mcnxisggc5vb4iq441ih6zm2n0a5lcd";
    };
    eula = true;
    declarative = true;
    whitelist = secrets.minecraft.allowList;
    serverProperties = {
      "server-port" = serverPort;
      "white-list" = true;
      "level-seed" = "6743789345153908210";
      "level-name" = "Mountain village";
    };
    jvmOpts = "-Xms512M -Xmx1024M -XX:+UseG1GC -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
  };

  systemd.services.minecraft-server.wantedBy = [];

  networking.firewall.allowedUDPPorts = [serverPort];
  networking.firewall.allowedTCPPorts = [serverPort];
}
