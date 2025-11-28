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

    user = mkOption {
      type = types.str;
      default = "byparr";
      description = "User account under which Byparr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "byparr";
      description = "Group under which Byparr runs.";
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

    users = {
      users = mkIf (cfg.user == "byparr") {
        byparr = {
          group = cfg.group;

          isSystemUser = true;

          home = "/var/lib/byparr";
        };
      };

      groups = mkIf (cfg.group == "byparr") {
        byparr = { };
      };
    };

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
        }
      ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        StateDirectory = "byparr";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "byparr";
        RuntimeDirectoryMode = "0750";

        EnvironmentFile = cfg.environmentFile;

        ExecStart = "${lib.getExe cfg.package}";

      };
    };
  };
}
