{
  self,
  ...
}@inputs:

let
  forAllSystems = inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed;

  overlayAllSystems =
    path:
    forAllSystems (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
        };

        flake = self;
      in
      import path { inherit flake pkgs; }
    );
in
{
  formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

  packages = overlayAllSystems ./packages;

  nixosModules = import ./modules;

  checks = overlayAllSystems ./tests;
}
