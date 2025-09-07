{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.libretranslate;

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    ;
in
{
  options.services.libretranslate = {
    enable = mkEnableOption "libretranslate";

    package = mkPackageOption pkgs "libretranslate" { };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };

      example = lib.literalExpression ''
        {
          LT_DISABLE_FILES_TRANSLATION = "true";
          LT_CHAR_LIMIT = "380";
        }
      '';

      # TODO: Link to docs/manpage
      description = ''
        Environment variables to pass to LibreTranslate.
      '';
    };

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];

      description = "Extra arguments to pass to `libretranslate`.";
    };

    port = mkOption {
      type = types.int;
      default = 5000;

      description = "Port to bind webserver.";
    };

    openFirewall = mkEnableOption "Whether to open the firewall for the port in {option}`services.libretranslate.port`.";
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.libretranslate = {
      description = "LibreTranslate free and open source machine translation API";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = cfg.environment // {
        HOME = "$STATE_DIRECTORY";
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        ExecStart = utils.escapeSystemdExecArgs (
          [
            "${cfg.package}/bin/libretranslate"
            "--port"
            (toString cfg.port)
          ]
          ++ cfg.extraArgs
        );

        UMask = "0077";

        DynamicUser = true;
        StateDirectory = "libretranslate";
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

  meta.maintainers = [ lib.maintainers.encode42 ];
}