{ lib, buildGoModule }:

buildGoModule rec {
  pname = "cgroup-exporter";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../go.mod
      ../go.sum
      (lib.fileset.fileFilter (file: file.hasExt "go") ../.)
      ../collector
    ];
  };

  vendorHash = "sha256-B9ppgJQout7eabd58iAAlgELRM4UFcNVhy50Hokhras=";

  passthru = { inherit version; };
}
