{
  pkgs,
  lib,
  fetchzip,
  ...
}:

let
  meta = {
    description = "LanguageTool n-gram data for finding additional errors";
    homepage = "https://languagetool.org";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ encode42 ];
  };

  baseURL = "https://languagetool.org/download/ngram-data/";

  availableDatasets = {
    de = {
      version = "2015-08-19";

      url = baseURL + "ngrams-de-20150819.zip";
      sha256 = "sha256-b+dPqDhXZQpVOGwDJOO4bFTQ15hhOSG6WPCx8RApfNg=";
    };

    en = {
      version = "2015-08-17";

      url = baseURL + "ngrams-en-20150817.zip";
      sha256 = "sha256-v3Ym6CBJftQCY5FuY6s5ziFvHKAyYD3fTHr99i6N8sE=";
    };

    es = {
      version = "2015-09-15";

      url = baseURL + "ngrams-es-20150915.zip";
      sha256 = "sha256-z+JJe8MeI9YXE2wUA2acK9SuQrMZ330QZCF9e234FCk=";
    };

    fr = {
      version = "2015-09-13";

      url = baseURL + "ngrams-fr-20150913.zip";
      sha256 = "sha256-mA2dFEscDNr4tJQzQnpssNAmiSpd9vaDX8e+21OJUgQ=";
    };

    he = {
      version = "2015-09-16";

      url = baseURL + "untested/ngram-he-20150916.zip";
      sha256 = "sha256-O/2H/u5Cv5HBMNI/rN47Rm9DF9J55Ogve1UuG7Hduxg=";
    };

    it = {
      version = "2015-09-15";

      url = baseURL + "untested/ngram-it-20150915.zip";
      sha256 = "sha256-5VSIDy+AXKehXlY2ssBbJt84PYhDa3VcU8VeDdiUHJk=";
    };

    nl = {
      version = "2018-12-29";

      url = baseURL + "ngrams-nl-20181229.zip";
      sha256 = "sha256-bHOEdb2R7UYvXjqL7MT4yy3++hNMVwnG7TJvvd3Feg8=";
    };

    ru = {
      version = "2015-09-14";

      url = baseURL + "untested/ngram-ru-20150914.zip";
      sha256 = "sha256-X2/TLHJHSylIaHYLbuWxHZ8zVjawv5w35niaHBM7pOg=";
    };

    zh = {
      version = "2015-09-16";

      url = baseURL + "untested/ngram-zh-20150916.zip";
      sha256 = "sha256-4BaskFHg8ReM8+fauj+/Gd+JAr/w/oFYgQxl/cEfIW4=";
    };
  };

  mkDatasetPackage =
    language:
    {
      version,
      url,
      sha256,
    }:
    pkgs.stdenv.mkDerivation rec {
      pname = "languagetool-ngrams-${language}";
      inherit version meta;

      src = fetchzip {
        inherit url sha256;
      };

      installPhase = ''
        mkdir -p $out/share/${pname}
        cp -r * $out/share/${pname}/
      '';
    };

  datasetPackages = lib.mapAttrs mkDatasetPackage availableDatasets;

  prefixedDatasetPackages = lib.listToAttrs (
    map (language: {
      name = "languagetool-ngrams-${language}";
      value = datasetPackages.${language};
    }) (lib.attrNames datasetPackages)
  );

  combinedPackage = pkgs.stdenv.mkDerivation rec {
    inherit meta;

    pname = "languagetool-ngrams";
    version = "2025-09-12";

    unpackPhase = "true";

    installPhase = ''
      mkdir -p $out/share/${pname}

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (language: package: ''
          cp -r ${package}/share/${pname}-${language} $out/share/${pname}/${language}
        '') datasetPackages
      )}
    '';
  };
in
prefixedDatasetPackages
// {
  languagetool-ngrams = combinedPackage;
}
