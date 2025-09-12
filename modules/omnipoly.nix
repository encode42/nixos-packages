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
      default = 80;

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
      after = [ "network.target" ];

      environment = cfg.environment // {
        PORT = toString cfg.port;
      };

      script = ''
        exec ${pkgs.nodejs}/bin/node ${cfg.package}/share/omnipoly/index.js
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        EnvironmentFile = cfg.environmentFile;

        UMask = "0077";

        DynamicUser = true;
        StateDirectory = "omnipoly";
        StateDirectoryMode = "0700";

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        LimitNOFILE = 65536;
        TimeoutStopSec = 5;
        KillSignal = "INT";
        SendSIGKILL = "yes";
        SuccessExitStatus = 0;

        ProtectHome = true;
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectHostname = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        PrivateUsers = true;
        PrivateDevices = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        LockPersonality = true;
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        CapabilityBoundingSet = [ "" ];
      };
    };
  };
}
