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
        overlays = [
          (final: prev: {
            rustc = prev.rustc.overrideAttrs (oA: {
              RUSTFLAGS = "-Ccodegen-units=32";
              postConfigure = oA.postConfigure + ''
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                exit 1
                substituteInPlace config.toml \
                  --replace '#docs = true' 'docs = false'
              '';
            });
          })
        ];
      };
    in
    {
      packages.x86_64-linux.rustc = pkgs.rustc.override {
        stdenv = pkgs.stdenv.override {
          targetPlatform = thumbv7emPkgs.stdenv.targetPlatform;
          hostPlatform = pkgs.stdenv.hostPlatform;
          buildPlatform = pkgs.stdenv.buildPlatform;
          #{ rustc.config = "thumbv7em-none-eabi"; };
          #targetPlatform = nixpkgs.lib.recursiveUpdate pkgs.multiStdenv.hostPlatform {
          #  rustc.config = "thumbv7em-none-eabi";
          #};
          #targetPlatform = thumbv7emPkgs.stdenv.targetPlatform;
        };
        pkgsBuildBuild = pkgs;
        pkgsBuildHost = pkgs;
        pkgsBuildTarget.targetPackages.stdenv.cc = pkgs.pkgsCross.arm-embedded.stdenv.cc;
        #gcc-arm-embedded;
        #thumbv7emPkgs.targetPackages.stdenv.cc;
        #= nixpkgs.lib.recursiveUpdate pkgs {
        #  targetPackages 
        #};
#        pkgsBuildTarget = thumbv7emPkgs;
        enableRustcDev = false;
      };
      packages.x86_64-linux.default = pkgs.callPackage ./package.nix {
        rustPlatform = pkgs.makeRustPlatform {
          inherit (pkgs.pkgsCross.arm-embedded) rustc;
          inherit (pkgs) cargo;
        };
      };
    };
}
