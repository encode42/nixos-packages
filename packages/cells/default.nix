{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cells";
  version = "4.4.15";

  src = fetchFromGitHub {
    owner = "pydio";
    repo = "cells";
    tag = "v${version}";
    hash = "sha256-cxKIx9xyU7G5U0eKCfX2S69VybFscgLic3OaqG/gsFY=";
  };

  vendorHash = "sha256-v23Ep9mTyG8fe5xa9ay9T4/ZEBU9LQHj6keIPZmm5d0=";

  ldflags = [ "-s" "-w" "-X github.com/pydio/cells/v4/common.version=${src.tag}" "-X github.com/pydio/cells/v4/common.BuildRevision=${version}" "-X github.com/pydio/cells/v4/common.BuildStamp=1970-01-01T00:00:00" ];

  excludedPackages = [ "cmd/cells-fuse" "cmd/protoc-gen-go-client-stub" "cmd/protoc-gen-go-enhanced-grpc" ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  checkFlags =
    let
      skippedTests = [
        # Skip tests that require network access
        "TestWGetAction_Run"
        "TestGetTimeFromNtp"

        # This test takes a *very* long time to complete
        "TestConcurrentReceivesGetAllTheMessages"
      ];
    in
    [ "-v" "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  meta = {
    description = "Future-proof content collaboration platform";
    homepage = "https://www.pydio.com/";
    changelog = "https://github.com/pydio/cells/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "cells";
  };
}
