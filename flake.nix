{
  description = "Dalamud branch packages and sdk versions";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
          branchData = (lib.importJSON ./dalamud-branches.json).branches;
        in
        forAllSystems (
          system: pkgs:
          let
            mkDalamud =
              name: branch:
              pkgs.stdenvNoCC.mkDerivation {
                pname = "dalamud-${name}";
                version = branch.version;
                src = pkgs.fetchzip {
                  url = branch.downloadUrl;
                  hash = branch.nix.hash;
                  extension = "zip";
                  stripRoot = false;
                };
                installPhase = "cp -r . $out";
                passthru = {
                  dotnetSdk =
                    pkgs.dotnetCorePackages.${branch.nix.dotnetSdkVersion}
                      or (throw "dalamud: unknown .NET SDK '${branch.nix.dotnetSdkVersion}'");
                };
                meta = {
                  description = "Dalamud plugin framework (${name} channel) v${branch.version}";
                  homepage = "https://github.com/goatcorp/Dalamud";
                  license = lib.licenses.agpl3Only;
                };
              };
            branches = lib.mapAttrs mkDalamud branchData;
          in
          branches // { default = branches.release; }
        );
    };
}
