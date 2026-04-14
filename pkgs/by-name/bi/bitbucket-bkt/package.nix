{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bitbucket-bkt";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "bitbucket-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fdTvD/S8Sd5Qu+udzNjDDsU2a2cw1WL2NeCgYcICxpQ=";
  };

  vendorHash = "sha256-6H4+CHSXJYRDlx12Iz9R129VIiA0NB/5g7JMgGwYwkE=";

  subPackages = [ "cmd/bkt" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/avivsinai/bitbucket-cli/internal/build.versionFromLdflags=${finalAttrs.version}"
    "-X github.com/avivsinai/bitbucket-cli/internal/build.commitFromLdflags=unknown"
    "-X github.com/avivsinai/bitbucket-cli/internal/build.dateFromLdflags=unknown"
  ];

  # Some tests (internal/remote) shell out to git, which is not available in
  # the Nix sandbox by default. To re-enable: add git to nativeBuildInputs
  # and verify internal/remote tests pass in sandbox; pkg/oauth tests
  # (net/http/httptest-backed) should pass without extra inputs.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bitbucket CLI for Data Center and Cloud, built for AI and automation";
    longDescription = ''
      A Bitbucket CLI for Data Center and Cloud, designed for AI workflows and
      automation in the style of GitHub's gh CLI.

      Note: the OAuth browser-based login flow (bkt auth login --web) is not
      functional in the nixpkgs build because it requires the upstream author's
      private Bitbucket Cloud OAuth client credentials. To use this feature,
      register a Bitbucket Cloud OAuth consumer and set:
        export BKT_OAUTH_CLIENT_ID=<your-client-id>
        export BKT_OAUTH_CLIENT_SECRET=<your-client-secret>
      All other authentication methods (app passwords, tokens) work normally.
    '';
    homepage = "https://github.com/avivsinai/bitbucket-cli";
    changelog = "https://github.com/avivsinai/bitbucket-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "bkt";
    maintainers = with lib.maintainers; [ vinylen ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
