{ writeShellApplication, skopeo, container }:
writeShellApplication {
  name = "push-container";
  runtimeInputs = [ skopeo ];
  runtimeEnv.imageTag = container.imageTag;
  text = ''
    args=()
    if [ "''${DO_TAG:-0}" == "1" ]; then
      args+=(--additional-tag "$imageTag")
    fi
    ${container} | skopeo copy docker-archive:/dev/stdin "docker://''${1}@@unknown-digest@@" "''${args[@]}"
  '';
}
