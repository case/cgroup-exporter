{ writeShellApplication, skopeo, container }:
writeShellApplication {
  name = "push-container";
  runtimeInputs = [ skopeo ];
  runtimeEnv.imageTag = container.imageTag;
  text = ''
    ${container} | skopeo copy docker-archive:/dev/stdin "docker://''${1}"
  '';
}
