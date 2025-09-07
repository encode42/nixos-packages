{ pkgs, ... }:

rec {
  #byparr = pkgs.callPackage ./byparr { };
  cells = pkgs.callPackage ./cells { };
  #decluttarr = pkgs.callPackage ./decluttarr { };
  #doreah = pkgs.callPackage ./doreah { };
  #maloja = pkgs.callPackage ./maloja { inherit psutil doreah nimrodel; };
  #nimrodel = pkgs.callPackage ./nimrodel { inherit doreah; };
  omnipoly = pkgs.callPackage ./omnipoly { };
  #psutil = pkgs.callPackage ./psutil { };
}