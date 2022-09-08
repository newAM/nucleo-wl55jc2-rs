{ lib
, rustPlatform
, lld
}:

let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in
rustPlatform.buildRustPackage {
  inherit (cargoToml.package) version;
  pname = cargoToml.package.name;

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    lld
  ];

  # no tests for no_std
  doCheck = false;

  meta = with lib; {
    inherit (cargoToml.package) description;
    licenses = with licenses; [ mit ];
  };
}
