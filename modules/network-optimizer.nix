{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.network-optimizer;

  pkgs-internal = import ../packages { inherit pkgs; };

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.network-optimizer = {
    enable = mkEnableOption "network-optimizer";

    package = mkOption {
      type = types.package;
      default = pkgs-internal.network-optimizer;

      description = "The NetworkOptimizer package to use.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = lib.literalExpression ''
        {
          HOST_IP = "192.168.1.100";

          TZ = "America/New_York";
          BIND_LOCALHOST_ONLY = true;
        }
      '';
      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to the [NetworkOptimization documentation] for the list of available
        configuration options.

        [NetworkOptimization documentation]: https://github.com/Ozark-Connect/NetworkOptimizer/blob/f0e6a0b48eb07ea73797e1970a8f3dbc88b97d8c/docker/.env.example
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

    port = mkOption {
      type = types.int;
      default = 8042;

      description = "Port to bind webserver.";

      example = 8042;
    };

    openFirewall = mkEnableOption "" // {
      description = "Whether to open the firewall for the port in {option}`services.network-optimizer.port`.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services.network-optimizer = {
      description = "NetworkOptimizer self-hosted performance optimization and security audit tool for UniFi Networks";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = lib.mkMerge [
        cfg.environment
        {
          ASPNETCORE_HTTP_PORTS = toString cfg.port;
        }
      ];

      path = with pkgs; [
        sshpass
        iperf3
      ];

      serviceConfig = {
        DynamicUser = true;

        StateDirectory = "network-optimizer";
        StateDirectoryMode = "0700";
        UMask = "0077";

        WorkingDirectory = "/var/lib/network-optimizer";

        ExecStart = lib.getExe cfg.package;

        EnvironmentFile = cfg.environmentFile;

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
      };
    };
  };
}
