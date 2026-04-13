# Dalamud Packages

Dalamud packaged as a Nix flake.

## Usage

### Plugins / Dalamud Packager Projects

If you are using `Dalamud.Net.Sdk` the following is already done for you. Otherwise, add the following to your `.csproj` or `.targets` file, replacing any existing definitions of the `DalamudLibPath` property.

```xml
<PropertyGroup>
  <DalamudLibPath Condition="$([MSBuild]::IsOSPlatform('Windows'))">$(appdata)\XIVLauncher\addon\Hooks\dev\</DalamudLibPath>
  <DalamudLibPath Condition="$([MSBuild]::IsOSPlatform('Linux'))">$(HOME)/.xlcore/dalamud/Hooks/dev/</DalamudLibPath>
  <DalamudLibPath Condition="$([MSBuild]::IsOSPlatform('OSX'))">$(HOME)/Library/Application Support/XIV on Mac/dalamud/Hooks/dev/</DalamudLibPath>
  <DalamudLibPath Condition="$(DALAMUD_HOME) != ''">$(DALAMUD_HOME)/</DalamudLibPath>
</PropertyGroup>
```

## Nix Flake

Add the flake as an input:

```nix
inputs.dalamud = { 
  url = "github:Blooym/dalamud-nix";
  # inputs.nixpkgs.follows = "nixpkgs"; # follow your local nixpkgs instead.
};
```

Then use it in your dev shell, or elsewhere, replacing `<branch>` with your desired branch:

```nix
pkgs.mkShell {
  packages = [
    inputs.dalamud.packages.${system}.<branch>.dotnetSdk # Dalamud's Dotnet SDK version
  ];
  env.DALAMUD_HOME = inputs.dalamud.packages.${system}.<branch>; # Dalamud files
};
```
