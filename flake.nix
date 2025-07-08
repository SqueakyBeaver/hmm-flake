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
        pname = "hedgemodmanager";
        version = "8.0.0.4";

        pkgs = import nixpkgs {
          inherit system;
        };

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
        dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;
      in {
        packages.default = pkgs.buildDotnetModule rec {
          inherit pname version dotnet-runtime dotnet-sdk;

          src = pkgs.fetchgit {
            url = "https://github.com/hedge-dev/HedgeModManager.git";
            deepClone = true; # Needed for the fucking stupid nerbank gitversionin
            rev = "da0b8b40b6e3da31d92ad0c58d683e1588e73eaf";
            hash = "sha256-WFyr61WoBI4Oxd3WbuY3WT5b7SqXqUUo3ATc4R02g0s=";
          };

          projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";
          nugetDeps = ./deps.json;

          dotnetBuildFlags = ["-p:DefineConstants=COMMITBUILD"];

          # From the nixpkgs implementation
          postPatch = ''
            substituteInPlace flatpak/hedgemodmanager.desktop --replace-fail "/app/bin/HedgeModManager.UI" "HedgeModManager.UI"
          '';

          # https://github.com/hedge-dev/HedgeModManager/blob/8.0.0-beta4/flatpak/io.github.hedge_dev.hedgemodmanager.yml#L53-L55
          postInstall = ''
            install -Dm644 flatpak/hedgemodmanager.png $out/share/icons/hicolor/256x256/apps/io.github.hedge_dev.hedgemodmanager.png
            install -Dm644 flatpak/hedgemodmanager.metainfo.xml $out/share/metainfo/io.github.hedge_dev.hedgemodmanager.metainfo.xml
            install -Dm644 flatpak/hedgemodmanager.desktop $out/share/applications/io.github.hedge_dev.hedgemodmanager.desktop
          '';

          passthru.updateScript = pkgs.nix-update-script {
            extraArgs = [
              "--version"
              "unstable"
            ];
          };

          meta = with pkgs.lib; {
            mainProgram = "HedgeModManager.UI";
            platforms = ["x86_64-linux"];
            homepage = "https://github.com/hedge-dev/HedgeModManager";
            description = "Multiplatform rewrite of Hedge Mod Manager";
            license = licenses.mit;
          };
        };

        apps.default = flake-utils.lib.mkApp {drv = self.packages.${system}.default;};
      }
    );
}
