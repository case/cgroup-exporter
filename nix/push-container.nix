{ writeShellApplication, skopeo, container, jq }:
writeShellApplication {
  name = "push-container";
  runtimeInputs = [ skopeo jq ];
  runtimeEnv.conf = container.passthru.conf;
  runtimeEnv.imageTag = container.passthru.imageTag;
  text = ''
    ${container} | skopeo copy docker-archive:/dev/stdin "docker://ghcr.io/''${GITHUB_REPOSITORY}:''${imageTag}" --dest-username "$GITHUB_ACTOR" --dest-password "$GITHUB_TOKEN" --digestfile digest
  '';
}
