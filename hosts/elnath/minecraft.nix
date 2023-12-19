{
  pkgs,
  ...
}: let
  serverPort = 36456;
in {
  services.minecraft-server = {
    enable = false;
    package = pkgs.unstable.minecraft-server.override {
      version = "1.20.4";
      url = "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar";
      sha1 = "9mcnxisggc5vb4iq441ih6zm2n0a5lcd";
    };
    eula = true;
    declarative = true;
    whitelist = {
      voidcontext = "8488f0e8-5594-4b74-84aa-6ac7ceafe64b";
    };
    serverProperties = {
      "server-port" = serverPort;
      "white-list" = true;
    };
    jvmOpts = "-Xms1024M -Xmx1024M -XX:+UseG1GC -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
  };

  # networking.firewall.allowedUDPPorts = [serverPort];
  # networking.firewall.allowedTCPPorts = [serverPort];

}
