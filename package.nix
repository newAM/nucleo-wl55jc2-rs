{ lib
#, rustPlatform
, buildRustPackage
}:

let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in
#rustPlatform.buildRustPackage {
buildRustPackage {
  inherit (cargoToml.package) version;
  pname = cargoToml.package.name;

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  # no tests for no_std
  doCheck = false;

  meta = with lib; {
    inherit (cargoToml.package) description;
    licenses = with licenses; [ mit ];
  };
}
