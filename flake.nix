{
  description = "Dalamud branch packages and sdk versions";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      forAllSystems =
        function:
        lib.genAttrs lib.systems.flakeExposed (system: (function system nixpkgs.legacyPackages.${system}));
    in
    {
      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = with pkgs; [
              python3
              ruff
            ];
          };
        }
      );

      packages =
        let
          sources = lib.importJSON ./dalamud-branches.json;
        in
        forAllSystems (
          system: pkgs:
          let
            mkDalamud =
              name: source:
              let
                sdk =
                  pkgs.dotnetCorePackages.${source.nix.dotnetSdkVersion}
                    or (throw "dalamud: unknown .NET SDK '${source.nix.dotnetSdkVersion}'");
              in
              pkgs.stdenvNoCC.mkDerivation {
                pname = "dalamud-${name}";
                version = source.version;
                src = pkgs.fetchzip {
                  url = source.downloadUrl;
                  hash = source.nix.hash;
                  extension = "zip";
                  stripRoot = false;
                };
                installPhase = "cp -r . $out";
                passthru = {
                  inherit sdk;
                };
                meta = {
                  description = "Dalamud plugin framework (${name} channel) v${source.version}";
                  homepage = "https://github.com/goatcorp/Dalamud";
                  license = lib.licenses.agpl3Only;
                };
              };
            branches = lib.mapAttrs mkDalamud sources;
          in
          branches // { default = branches.release; }
        );
    };
}
