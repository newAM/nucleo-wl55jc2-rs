{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      thumbv7emPkgs = import nixpkgs {
        crossSystem = nixpkgs.lib.systems.examples.arm-embedded // {
          rustc.config = "thumbv7em-none-eabi";
        };
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
      };
    in
    {
      packages.x86_64-linux.default = thumbv7emPkgs.callPackage ./package.nix { };
    };
}
