{ writeShellApplication, skopeo, container }:
writeShellApplication {
  name = "push-container";
  runtimeInputs = [ skopeo ];
  runtimeEnv = { inherit (container) imageTag imageName };
  text = '' 
    ${container} | skopeo copy docker-archive:/dev/stdin "docker://ghcr.io/$${GITHUB_REPOSITORY}@@unknown-digest@@" --dest-username "$GITHUB_ACTOR" --dest-password "$GITHUB_TOKEN"
  '';
}
