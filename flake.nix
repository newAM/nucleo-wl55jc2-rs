{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      thumbv7emPkgs = import nixpkgs {
        crossSystem = nixpkgs.lib.systems.examples.arm-embedded // {
          rustc.config = "thumbv7em-none-eabi";
        };
        config.allowUnsupportedSystem = true;
        system = "x86_64-linux";
        overlays = [
          (final: prev: {
            rustc = prev.rustc.overrideAttrs (oA: {
              postConfigure = oA.postConfigure + ''
                substituteInPlace config.toml \
                  --replace '#docs = true' 'docs = false`
              '';
            });
          })
        ];
      };
    in
    {
      packages.x86_64-linux.default = thumbv7emPkgs.callPackage ./package.nix { };
    };
}
