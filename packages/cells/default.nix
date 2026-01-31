{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cells";
  version = "4.4.17";

  src = fetchFromGitHub {
    owner = "pydio";
    repo = "cells";
    tag = "v${version}";
    hash = "sha256-p2/H75n1ZTnAuTHmJiaVt82t5OVk85ah8Zmgey0mF58=";
  };

  vendorHash = "sha256-9jPjlAUtMQe0y2Eubv4O6i+Bl3QOmdBxbCnrHKbubo0=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/pydio/cells/v4/common.version=${src.tag}"
    "-X github.com/pydio/cells/v4/common.BuildRevision=${version}"
    "-X github.com/pydio/cells/v4/common.BuildStamp=1970-01-01T00:00:00"
  ];

  excludedPackages = [
    "cmd/cells-fuse"
    "cmd/protoc-gen-go-client-stub"
    "cmd/protoc-gen-go-enhanced-grpc"
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  checkFlags =
    let
      skippedTests = [
        # Skip tests that require network access
        "TestWGetAction_Run"
        "TestGetTimeFromNtp"

        # These tests take a *very* long time to complete
        "TestConcurrentReceivesGetAllTheMessages"
        "TestSizeRotation"
        "TestHandler_ReadNode"
        "TestMemory"
        "TestService"
        "TestProducer"

        # These tests take less time than above, but a while to complete
        # They are skipped since they likely passed before release
        "TestBoltMassivePurge"
        "TestInsertActivity"
        "TestMessageRepository"
        "TestGetSetMemory"
        "TestFlatFolderWithMassiveChildren"
        "TestShort"
        "TestSearchNode"
        "TestSearchByGeolocation"
        "TestDeleteNode"
        "TestClearIndex"
        "TestSearchByUuidsMatch"
        "TestIndexLongNode"
        "TestPatHandler_Generate"
        "TestPatHandler_AutoRefresh"
        "TestShareLinks"
      ];
    in
    [
      "-v"
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
    ];

  meta = {
    description = "Future-proof content collaboration platform";
    homepage = "https://www.pydio.com/";
    changelog = "https://github.com/pydio/cells/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "cells";
  };
}
