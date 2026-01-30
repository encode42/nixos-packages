{ flake, pkgs }:

let
  mkTest =
    path:
    import path {
      inherit flake pkgs;

      lib = pkgs.lib;
    };
in
{
  byparr = mkTest ./byparr.nix;
  cells = mkTest ./cells.nix;
  #maloja = mkTest ./maloja.nix;
  network-optimizer = mkTest ./network-optimizer.nix;
  omnipoly = mkTest ./omnipoly.nix;
}
