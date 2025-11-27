{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.byparr;

  pkgs-internal = import ../packages { inherit pkgs; };

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.byparr = {
    enable = mkEnableOption "byparr";

    package = mkOption {
      type = types.package;
      default = pkgs-internal.byparr;

      description = "The Byparr package to use.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };

      example = lib.literalExpression ''
        {
          PROXY_SERVER = "";
        }
      '';

      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to the [Byparr documentation] for the list of available
        configuration options.

        [Byparr documentation]: https://github.com/ThePhaseless/Byparr/blob/916005e039ffdc38c9db8cba9f10d5f16b8457f3/README.md#options
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "localhost";

      description = "Host to bind webserver";

      example = "0.0.0.0";
    };

    port = mkOption {
      type = types.int;
      default = 8191;

      description = "Port to bind webserver.";

      example = 8191;
    };

    openFirewall = mkEnableOption "" // {
      description = "Whether to open the firewall for the port in {option}`port`.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services.byparr = {
      description = "Byparr provides http cookies and headers for websites protected with anti-bot protections";

      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ];

      environment = lib.mkMerge [
        cfg.environment
        {
          HOST = cfg.host;
          PORT = toString cfg.port;

          XDG_CACHE_HOME = "/run/byparr/cache";
        }
      ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "byparr";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "byparr";
        RuntimeDirectoryMode = "0750";
        UMask = "0077";

        EnvironmentFile = cfg.environmentFile;

        ExecStart = "${lib.getExe cfg.package}";

        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.port}";
        SocketBindDeny = "any";
        SystemCallArchitectures = "native";
      };
    };
  };
}
