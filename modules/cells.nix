{
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  cfg = config.services.cells;
  format = pkgs.formats.json { };

  pkgs-internal = import ../packages { inherit pkgs; };

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.cells = {
    enable = mkEnableOption "Whether to enable Pydio Cells content collaboration platform.";

    package = mkOption {
      type = types.package;
      default = pkgs-internal.cells;

      description = "The Pydio Cells package to use.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];

      description = ''
        Additional groups for the systemd service.
      '';
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };

      example = lib.literalExpression ''
        {
          CELLS_BIND_ADDRESS = "127.0.0.1";
          CELLS_BIND = "8080";

          CELLS_DAV_MULTIPART_SIZE = 100;
          CELLS_CONFIG = "/opt/pydio.json";
        }
      '';

      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to the [Pydio Cells documentation] for the list of available
        configuration options. Variable name is an upper-cased coommand flag,
        prefixed with `CELLS_`. For example, the `bind_address` entry can be
        set using {env}`CELLS_BIND_ADDRESS`.

        Pydio Cells is designed to be configured on installation, with certain
        configuration options such as database credentials being defined
        elsewhere. See {option}`install` for initial configuration options.

        [Pydio Cells documentation]: https://pydio.com/en/docs/developer-guide/cells-start
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

    database = {
      enable =
        mkEnableOption "The MySQL database to use with Pydio Cells. See {option}`services.mysql`"
        // {
          default = true;
        };

      createDB = mkEnableOption "The automatic creation of the database for Pydio Cells." // {
        default = true;
      };

      name = mkOption {
        type = types.str;
        default = "cells";

        description = "The name of the Pydio Cells database.";
      };

      user = mkOption {
        type = types.str;
        default = "cells";

        description = "The database user for Pydio Cells.";
      };
    };

    stateDirectory = mkOption {
      type = types.str;
      default = "pydio";

      description = ''
        Directory for Pydio Cells state
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8080;

      description = ''
        Port used by Pydio Cells.

        Note that this *will not* set the port that Pydio Cells listens on!
      '';
    };

    openFirewall = mkEnableOption "Open ports in the firewall for the cells web interface.";
  };

  config = mkIf cfg.enable {
    services.mysql = mkIf cfg.database.enable {
      enable = true;

      ensureDatabases = mkIf cfg.database.createDB [ cfg.database.name ];
      ensureUsers = mkIf cfg.database.createDB [
        {
          name = cfg.database.user;
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };
        }
      ];

      package = lib.mkDefault pkgs.mariadb_114;
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.cells = {
      description = "Pydio Cells content collaboration platform";

      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ] ++ lib.optional cfg.database.enable "mysql.service";

      environment = cfg.environment // {
        CELLS_LOG_DIR = "$LOGS_DIRECTORY";
        CELLS_WORKING_DIR = "$STATE_DIRECTORY";
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        ExecStart = "${lib.getExe cfg.package} start";

        UMask = "0077";

        SupplementaryGroups = cfg.extraGroups;

        DynamicUser = true;
        StateDirectory = cfg.stateDirectory;
        StateDirectoryMode = "0700";
        CacheDirectory = "pydio";
        CacheDirectoryMode = "0700";
        LogsDirectory = "pydio";
        LogsDirectoryMode = "0700";

        EnvironmentFile = cfg.environmentFile;

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        LimitNOFILE = 65536;
        TimeoutStopSec = 5;
        KillSignal = "INT";
        SendSIGKILL = "yes";
        SuccessExitStatus = 0;

        ProtectHome = true;
        # TODO: one of these commented options are causing panics
        #ProtectProc = "invisible";
        ProtectClock = true;
        ProtectHostname = true;
        #ProtectControlGroups = true;
        #ProtectKernelLogs = true;
        #ProtectKernelModules = true;
        #ProtectKernelTunables = true;
        PrivateUsers = true;
        PrivateDevices = true;
        RestrictRealtime = true;
        RestrictNamespaces = [
          "user"
          "mnt"
        SocketBindAllow = "tcp:${toString cfg.port}";
        SocketBindDeny = "any";
        ];
        #RestrictAddressFamilies = [
        #  "AF_INET"
        #  "AF_INET6"
        #  "AF_UNIX"
        #];
        LockPersonality = true;
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        CapabilityBoundingSet = [ "" ];
      };
    };
  };

  meta.maintainers = [ lib.maintainers.encode42 ];
}
