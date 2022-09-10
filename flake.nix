{
  inputs.nixpkgs.url = "github:newAM/nixpkgs/rustc-fix-embedded";

  outputs = { self, nixpkgs }:
    let
      thumbv7emPkgs = import nixpkgs {
        system = "x86_64-linux";
        crossSystem = nixpkgs.lib.systems.examples.arm-embedded // {
          rustc.config = "thumbv7em-none-eabi";
        };
        config.allowUnsupportedSystem = true;
      };
    in
    {
      packages.x86_64-linux.default = thumbv7emPkgs.callPackage ./package.nix { };
    };
}
