{ pkgs, ... }:

let
  languagetool-packages = pkgs.callPackage ./languagetool-ngrams { };
in
rec {
  #byparr = pkgs.callPackage ./byparr { };
  cells = pkgs.callPackage ./cells { };
  #decluttarr = pkgs.callPackage ./decluttarr { };
  #doreah = pkgs.callPackage ./doreah { };
  iso2god-rs = pkgs.callPackage ./iso2god-rs { };
  #maloja = pkgs.callPackage ./maloja { inherit doreah nimrodel; };
  #nimrodel = pkgs.callPackage ./nimrodel { inherit doreah; };
  omnipoly = pkgs.callPackage ./omnipoly { };
  slskd = pkgs.callPackage ./slskd { };

  inherit (languagetool-packages)
    languagetool-ngrams
    languagetool-ngrams-de
    languagetool-ngrams-en
    languagetool-ngrams-es
    languagetool-ngrams-fr
    languagetool-ngrams-he
    languagetool-ngrams-it
    languagetool-ngrams-nl
    languagetool-ngrams-ru
    languagetool-ngrams-zh
    ;
}
