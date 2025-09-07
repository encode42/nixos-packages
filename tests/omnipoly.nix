{ flake, pkgs, ... }:

pkgs.nixosTest {
  name = "omnipoly-test";

  nodes.machine = { ... }: {
    imports = [
      flake.nixosModules.omnipoly
    ];

    services.languagetool = {
      enable = true;
    };

    # TODO: start and configure languagetool
    # TODO: start and configure libretranslate

    services.omnipoly = {
      enable = true;

      port = 5000;

      environment = {
        LANGUAGE_TOOL = "https://127.0.01:8081";
      };
    };
  };

  # TODO: This is a very basic test

  testScript = ''
    machine.start()
    machine.wait_for_unit("omnipoly.service")
    machine.succeed("systemctl is-active omnipoly.service")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
