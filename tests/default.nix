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
  libretranslate = mkTest ./libretranslate.nix;
  #maloja = mkTest ./maloja.nix;
  omnipoly = mkTest ./omnipoly.nix;
}
