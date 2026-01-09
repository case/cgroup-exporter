{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [ ./nix/module.nix ];

        services.prometheus.exporters.cgroup.package =
          lib.mkDefault self.packages.${pkgs.system}.default;
      };

      overlays.default = final: prev: {
        cgroup-exporter = final.callPackage ./nix/package.nix { };
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          cgroup-exporter = pkgs.callPackage ./nix/package.nix { };
        in rec {
          default = cgroup-exporter;
          container = pkgs.callPackage ./nix/container.nix {
	    inherit cgroup-exporter;
          };
	  push-container = pkgs.callPackage ./nix/push-container.nix {
	    inherit container;
	  };
        });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      devShells = forAllSystems (system: {
        default = with nixpkgs.legacyPackages.${system};
          mkShell {
            name = "cgroups-exporter";
            nativeBuildInputs = [ go ];
          };
      });

      checks = forAllSystems (system: {
        package = self.packages.${system}.default;
        integration-test = nixpkgs.lib.nixos.runTest {
          name = "cgroup-exporter";
          hostPkgs = nixpkgs.legacyPackages.${system};
          nodes.machine = {
            imports = [ self.nixosModules.default ];
            services.prometheus.exporters.cgroup.enable = true;
            services.prometheus.exporters.cgroup.port = 8080;
          };
          testScript = ''
            machine.wait_for_unit("cgroup-exporter.service");
            machine.succeed("curl http://localhost:8080/metrics");
          '';
        };
      });
    };
}
