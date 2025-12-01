{
  flake,
  pkgs,
  lib,
  ...
}:

let
  byparrPort = 8191;
in
pkgs.testers.nixosTest {
  name = "byparr-test";

  nodes.machine =
    { config, ... }:
    {
      imports = [
        flake.nixosModules.byparr
      ];

      virtualisation.diskSize = 4096;

      networking.firewall.enable = false;
      networking.useDHCP = true;

      services.byparr = {
        enable = true;

        port = byparrPort;
      };
    };

  testScript = ''
    machine.start()

    machine.wait_for_unit("byparr.service")
    machine.wait_for_open_port(${toString byparrPort})

    machine.succeed("curl -L -X POST 'http://localhost:8191/v1' -H 'Content-Type: application/json' --data-raw '{ \"cmd\": \"request.get\", \"url\": \"http://www.google.com/\", \"maxTimeout\": 60000 }'")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
