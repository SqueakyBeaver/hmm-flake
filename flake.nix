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
  } @ inputs:
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
            url = "https://github.com/hedge-dev/HedgeModManager";
            hash = "sha256-ApdD9Pr5/ujpvFwmZiZPVQOCWnoxreFgxHKdu6eRis0=";
            rev = "74984e0813ae547d6b47e40d7432e923fce9ce58";
            leaveDotGit = true; # Needed for the fucking stupid nerbank gitversionin
          };

          projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";
          # projectFile = "Source/HedgeModManager";
          nugetDeps = ./deps.json;

          dotnetBuildFlags = ["-p:PublicRelease=true"];

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
