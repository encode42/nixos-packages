{ self, nixpkgs }:

let
  overlay = final: prev: import ./packages { pkgs = final; };

  forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

  overlayAllSystems =
    path:
    forAllSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };

        flake = self;
      in
      import path { inherit flake pkgs; }
    );
in
{
  formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

  overlays.default = overlay;

  packages = overlayAllSystems ./packages;

  nixosModules = import ./modules;

  checks = overlayAllSystems ./tests;
}
