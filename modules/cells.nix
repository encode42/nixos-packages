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

    user = mkOption {
      type = types.str;
      default = "pydio";
      description = "User account under which Pydio Cells runs.";
    };

    group = mkOption {
      type = types.str;
      default = "pydio";
      description = "Group under which Pydio Cells runs.";
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

    users = {
      users = mkIf (cfg.user == "pydio") {
        pydio = {
          group = cfg.group;
          isSystemUser = true;
        };
      };

      groups = mkIf (cfg.group == "pydio") {
        pydio = { };
      };
    };

    systemd.services.cells = {
      description = "Pydio Cells content collaboration platform";

      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ]
      ++ lib.optional cfg.database.enable "mysql.service";

      environment = cfg.environment;

      script = ''
        ${lib.concatLines (
          lib.mapAttrsToList
            (name: value: ''
              export ${name}="''${${name}-${value}}"
            '')
            {
              CELLS_WORKING_DIR = "$STATE_DIRECTORY";
              CELLS_LOG_DIR = "$LOGS_DIRECTORY";
            }
        )}

        exec ${lib.getExe cfg.package} start
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        SupplementaryGroups = cfg.extraGroups;

        StateDirectory = "pydio";
        StateDirectoryMode = "0700";
        LogsDirectory = "pydio";
        LogsDirectoryMode = "0750";
        UMask = "0077";

        EnvironmentFile = cfg.environmentFile;

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictNamespaces = [
          "user"
          "mnt"
        ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };
    };
  };

  meta.maintainers = [ lib.maintainers.encode42 ];
}
