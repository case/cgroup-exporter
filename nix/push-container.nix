{ writeShellApplication, skopeo, container }:
writeShellApplication {
  name = "push-container";
  runtimeInputs = [ skopeo ];
  text = '' 
    ${container} | skopeo copy docker-archive:/dev/stdin "ghcr.io/$GITHUB_REPOSITORY" --username "$GITHUB_ACTOR" --password "$GITHUB_TOKEN"
  '';
}
