{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.omnipoly;

  pkgs-internal = import ../packages { inherit pkgs; };

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    ;
in
{
  options.services.omnipoly = {
    enable = mkEnableOption "omnipoly";

    package = mkOption {
      type = types.package;
      default = pkgs-internal.omnipoly;

      description = "The OmniPoly package to use.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = lib.literalExpression ''
        {
          LIBRETRANSLATE_LANGUAGES = [ "pl" "en" ]; todo
          LANGUAGE_TOOL_LANGUAGES = [ "pl-PL" "en-GB" ]; todo
        }
      '';
      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to the [OmniPoly documentation] for the list of available
        configuration options.

        [OmniPoly documentation]: https://github.com/kWeglinski/OmniPoly/blob/d8fd6efec60fbc8703e2c60cffcc4fc452c76d36/.env.sample
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
      default = 5000;

      description = "Port to bind webserver.";

      example = 5000;
    };

    openFirewall = mkEnableOption "" // {
      description = "Whether to open the firewall for the port in {option}`services.omnipoly.port`.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services.omnipoly = {
      description = "OmniPoly frontend for LanguageTool and LibreTranslate";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]
      ++ lib.optional config.services.languagetool.enable "languagetool.service"
      ++ lib.optional config.services.libretranslate.enable "libretranslate.service";

      environment = lib.mkMerge [
        cfg.environment
        {
          PORT = toString cfg.port;
        }
        (mkIf config.services.languagetool.enable {
          LANGUAGE_TOOL = "http://127.0.0.1:${toString config.services.languagetool.port}";
        })
        (mkIf config.services.libretranslate.enable {
          LIBRETRANSLATE = "http://127.0.0.1:${toString config.services.libretranslate.port}";
        })
      ];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        EnvironmentFile = cfg.environmentFile;

        ExecStart = "${pkgs.nodejs}/bin/node ${cfg.package}/share/omnipoly/index.js";

        DynamicUser = true;
        StateDirectory = "omnipoly";
        StateDirectoryMode = "0700";
        UMask = "0077";

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
        RestrictAddressFamilies = [ "AF_INET AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.port}";
        SocketBindDeny = "any";
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };
    };
  };
}
