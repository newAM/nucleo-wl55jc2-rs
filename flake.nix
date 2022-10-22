{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
    crane.inputs.rust-overlay.follows = "rust-overlay";
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

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  in {
    packages.x86_64-linux.default = craneLib.buildPackage (nixpkgs.lib.recursiveUpdate
      commonArgs
      {
        inherit cargoArtifacts;
      });
  };
}
