{
  config,
  lib,
  pkgs,
  ...
}: let
  version = "1.20.51.01";
  versionUriSegment = builtins.replaceStrings ["-"] ["-"] version;
  libSha256 = lib.fakeSha256;
  serverSha256 = lib.fakeSha256;

  libCrypto = with pkgs;
    stdenv.mkDerivation rec {
      name = "${pname}-${version}";
      pname = "minecraft-bedrock-server-libcrypto";
      inherit version;
      src = fetchurl {
        url = "https://minecraft.azureedge.net/bin-linux/bedrock-server-${versionUriSegment}.zip";
        sha256 = libSha256;
      };
      sourceRoot = ".";
      nativeBuildInputs = [
        autoPatchelfHook
        curl
        gcc-unwrapped
        openssl
        unzip
      ];
      installPhase = ''
        install -m755 -D libCrypto.so  $out/lib/libCrypto.so
      '';
      fixupPhase = ''
        autoPatchelf $out/lib/libCrypto.so
      '';
    };

  minecraft-bedrock-server = with pkgs;
    stdenv.mkDerivation rec {
      name = "${pname}-${version}";
      pname = "minecraft-bedrock-server";
      inherit version;
      src = fetchurl {
        url = "https://minecraft.azureedge.net/bin-linux/bedrock-server-${versionUriSegment}.zip";
        sha256 = serverSha256;
      };
      sourceRoot = ".";
      nativeBuildInputs = [
        (patchelf.overrideDerivation (old: {
          postPatch = ''
            substituteInPlace src/patchelf.cc \
              --replace "32 * 1024 * 1024" "512 * 1024 * 1024"
          '';
        }))
        autoPatchelfHook
        curl
        gcc-unwrapped
        libCrypto
        openssl
        unzip
      ];
      installPhase = ''
        install -m755 -D bedrock_server $out/bin/bedrock_server
        rm bedrock_server
        rm libCrypto.so
        rm server.properties
        mkdir -p $out/var
        cp -a . $out/var/lib
      '';
      fixupPhase = ''
        autoPatchelf $out/bin/bedrock_server
      '';
    };
in
  with lib; let
    cfg = config.services.minecraft-bedrock-server;

    cfgToString = v:
      if builtins.isBool v
      then boolToString v
      else toString v;

    serverPropertiesFile = pkgs.writeText "server.properties" (''
        # server.properties managed by NixOS configuration
      ''
      + concatStringsSep "\n" (mapAttrsToList
        (n: v: "${n}=${cfgToString v}")
        cfg.serverProperties));

    defaultServerPort = 19132;

    serverPort = cfg.serverProperties.server-port or defaultServerPort;
  in {
    options = {
      services.minecraft-bedrock-server = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            If enabled, start a Minecraft Bedrock Server. The server
            data will be loaded from and saved to
            <option>services.minecraft-bedrock-server.dataDir</option>.
          '';
        };

        dataDir = mkOption {
          type = types.path;
          default = "/var/lib/minecraft-bedrock";
          description = ''
            Directory to store Minecraft Bedrock database and other state/data files.
          '';
        };

        allowList = mkOption {
          type = types.attrsOf types.string;
          default = {};
        };

        serverProperties = mkOption {
          type = with types; attrsOf (oneOf [bool int str]);
          default = {
            server-name = "Dedicated Server";
            gamemode = "survival";
            difficulty = "normal";
            allow-cheats = false;
            max-players = 10;
            online-mode = true;
            allow-list = true;
            server-port = 19132;
            server-portv6 = 19133;
            view-distance = 32;
            tick-distance = 4;
            player-idle-timeout = 30;
            max-threads = 4;
            level-name = "Bedrock level";
            level-seed = "";
            default-player-permission-level = "member";
            texturepack-required = false;
            content-log-file-enabled = false;
            compression-threshold = 1;
            server-authoritative-movement = "server-auth";
            player-movement-score-threshold = 20;
            player-movement-distance-threshold = 0.3;
            player-movement-duration-threshold-in-ms = 500;
            correct-player-movement = false;
          };
          example = literalExample ''
            {
              server-name = "Dedicated Server";
              gamemode = "survival";
              difficulty = "normal";
              allow-cheats = false;
              max-players = 10;
              online-mode = true;
              allow-list = true;
              server-port = 19132;
              server-portv6 = 19133;
              view-distance = 32;
              tick-distance = 4;
              player-idle-timeout = 30;
              max-threads = 4;
              level-name = "Bedrock level";
              level-seed = "";
              default-player-permission-level = "member";
              texturepack-required = false;
              content-log-file-enabled = false;
              compression-threshold = 1;
              server-authoritative-movement = "server-auth";
              player-movement-score-threshold = 20;
              player-movement-distance-threshold = 0.3;
              player-movement-duration-threshold-in-ms = 500;
              correct-player-movement = false;
            }
          '';
          description = ''
            Minecraft Bedrock server properties for the server.properties file.
          '';
        };

        package = mkOption {
          type = types.package;
          default = minecraft-bedrock-server;
          defaultText = "pkgs.minecraft-bedrock-server";
          example = literalExample "pkgs.minecraft-bedrock-server-1_16";
          description = "Version of minecraft-bedrock-server to run.";
        };
      };
    };

    config = mkIf cfg.enable (let
      allowlistFile =
        pkgs.writeText "allowlist.json"
        (builtins.toJSON
          (mapAttrsToList (n: v: {
              name = n;
              uuid = v;
            })
            cfg.allowList));
    in {
      users.users.minecraft-bedrock = {
        description = "Minecraft server service user";
        home = cfg.dataDir;
        createHome = true;
        uid = config.ids.uids.minecraft-bedrock;
      };

      systemd.services.minecraft-bedrock-server = {
        description = "Minecraft Bedrock Server Service";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/bedrock_server";
          Restart = "always";
          User = "minecraft-bedrock";
          WorkingDirectory = cfg.dataDir;
        };

        preStart = ''
          cp -a -n ${cfg.package}/var/lib/* .
          cp -f ${serverPropertiesFile} server.properties
          cp -f ${allowlistFile} allowlist.json
          chmod +w server.properties
        '';
      };

      networking.firewall = {
        allowedUDPPorts = [serverPort];
      };
    });
  }
