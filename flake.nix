{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            rustc = prev.rustc.overrideAttrs (oA: {
              RUSTFLAGS = "-Ccodegen-units=32";
              postConfigure = oA.postConfigure + ''
                substituteInPlace config.toml \
                  --replace '#docs = true' 'docs = false'
              '';
            });
          })
        ];
      };
      thumbv7emPkgs = import nixpkgs {
        system = "x86_64-linux";
        crossSystem = nixpkgs.lib.systems.examples.arm-embedded // {
          rustc.config = "thumbv7em-none-eabi";
        };
        config.allowUnsupportedSystem = true;
      };
    in
    rec {
      packages.x86_64-linux.rustc = pkgs.rustc.override {
        stdenv = pkgs.stdenv.override {
          targetPlatform = thumbv7emPkgs.stdenv.targetPlatform;
          hostPlatform = pkgs.stdenv.hostPlatform;
          buildPlatform = pkgs.stdenv.buildPlatform;
        };
        pkgsBuildBuild = pkgs;
        pkgsBuildHost = pkgs;
        pkgsBuildTarget.targetPackages.stdenv.cc = pkgs.pkgsCross.arm-embedded.stdenv.cc;
        enableRustcDev = false;
      };
      packages.x86_64-linux.rustPlatform = thumbv7emPkgs.makeRustPlatform {
        inherit (packages.x86_64-linux) rustc;
        inherit (pkgs) cargo;
      };
      packages.x86_64-linux.default = pkgs.callPackage ./package.nix {
        buildRustPackage = pkgs.callPackage "${nixpkgs}/pkgs/build-support/rust/build-rust-package" { 
            git = pkgs.gitMinimal;
            inherit (packages.x86_64-linux) rustc;
            stdenv = thumbv7emPkgs.stdenv.override {
              hostPlatform = thumbv7emPkgs.stdenv.targetPlatform;
              targetPlatform = thumbv7emPkgs.stdenv.targetPlatform;
              #buildPlatform = thumbv7emPkgs.stdenv.targetPlatform;
            };
            inherit (packages.x86_64-linux.rustPlatform) cargoBuildHook cargoCheckHook cargoInstallHook cargoSetupHook
              fetchCargoTarball importCargoLock;
          };
      };
    };
}
