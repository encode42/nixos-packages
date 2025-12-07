{ pkgs, ... }:

let
  languagetool-packages = pkgs.callPackage ./languagetool-ngrams { };
in
rec {
  captcha-python-async = pkgs.callPackage ./2captcha-python-async { };
  apify-fingerprint-datapoints = pkgs.callPackage ./apify-fingerprint-datapoints { };
  browserforge = pkgs.callPackage ./browserforge { inherit apify-fingerprint-datapoints; };
  byparr = pkgs.callPackage ./byparr { inherit camoufox playwright-captcha; };
  camoufox = pkgs.callPackage ./camoufox { inherit browserforge camoufox-browser; };
  camoufox-browser = pkgs.callPackage ./camoufox-browser { };
  cells = pkgs.callPackage ./cells { };
  collabora-online = pkgs.callPackage ./collabora-online { };
  #doreah = pkgs.callPackage ./doreah { };
  iso2god-rs = pkgs.callPackage ./iso2god-rs { };
  #libfreenect = pkgs.callPackage ./libfreenect { };
  #maloja = pkgs.callPackage ./maloja { inherit doreah nimrodel; };
  #nimrodel = pkgs.callPackage ./nimrodel { inherit doreah; };
  omnipoly = pkgs.callPackage ./omnipoly { };
  playwright-captcha = pkgs.callPackage ./playwright-captcha { inherit captcha-python-async; };
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
