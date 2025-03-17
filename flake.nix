{
  description = "AHedge Mod Manager 8";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      # Nothing else tested
    ] (
      system: let
        pname = "HedgeModManager.UI";
        version = "8.0.0-beta4";
        sha256 = "sha256-1uwcpeyOxwKI0fyAmchYEMqStF52wXkCZej+ZQ+aFeY=";

        pkgs = import nixpkgs {
          inherit system;
        };

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
        dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;
      in {
        packages.default = pkgs.buildDotnetModule {
          inherit pname version dotnet-runtime dotnet-sdk;

          src = pkgs.fetchFromGitHub {
            owner = "hedge-dev";
            repo = "HedgeModManager";
            tag = version;
            hash = sha256;
          };

          projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";
          nugetDeps = ./deps.json;

          meta = with pkgs.lib; {
            homepage = "https://github.com/hedge-dev/HedgeModManager";
            description = "Multiplatform rewrite of Hedge Mod Manager";
            license = licenses.mit;
          };

          postInstall = ''
            # Desktop file
            mkdir -p "$out/share/applications/"
            cp "$src/flatpak/hedgemodmanager.desktop" "$out/share/applications"
          '';
        };

        apps.default = flake-utils.lib.mkApp {drv = self.packages.${system}.default;};
      }
    );
}
