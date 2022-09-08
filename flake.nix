{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
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
        };
        pkgsBuildTarget.targetPackages.stdenv.cc = thumbv7emPkgs.stdenv.cc;
        enableRustcDev = false;
      };
      packages.x86_64-linux.rustPlatform = thumbv7emPkgs.makeRustPlatform {
        inherit (packages.x86_64-linux) rustc;
        inherit (pkgs) cargo;
      };
      packages.x86_64-linux.default = pkgs.callPackage ./package.nix {
        inherit (packages.x86_64-linux) rustPlatform;
      };
    };
}
