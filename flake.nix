{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    rust-overlay,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [(import rust-overlay)];
    };

    rustWithArm = pkgs.rust-bin.stable.latest.default.override {
      targets = ["thumbv7em-none-eabi"];
    };

    craneLib = (crane.mkLib pkgs).overrideToolchain rustWithArm;

    commonArgs = rec {
      src = ./.;

      cargoExtraArgs = "--target thumbv7em-none-eabi";

      # tests require std
      doCheck = false;

      nativeBuildInputs = with pkgs; [
        flip-link
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly (commonArgs
      // {
        # Adds !#[no_std] to top of dummy build file.
        # Replaces --all-targets with --lib --bins --tests
        # all-targets normally includes --benches and --tests as well, which
        # do not work for no_std targets.
        buildPhaseCargoCommand = ''
          sed -i '1s/^/#![no_std]/' src/lib.rs
          cargoWithProfile check --lib --bins --examples ${commonArgs.cargoExtraArgs}
          cargoWithProfile build ${commonArgs.cargoExtraArgs}
        '';
      });
  in {
    packages.x86_64-linux.default = craneLib.buildPackage (
      commonArgs
      // {
        inherit cargoArtifacts;
      }
    );
  };
}
