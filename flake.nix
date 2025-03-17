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
        packages.default = pkgs.buildDotnetModule rec {
          inherit pname version dotnet-runtime dotnet-sdk;

          src = pkgs.fetchFromGitHub {
            owner = "hedge-dev";
            repo = "HedgeModManager";
            tag = version;
            hash = sha256;
          };

          projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";
          nugetDeps = ./deps.json;

          desktopItems = [
            (pkgs.makeDesktopItem {
              name = pname;
              exec = meta.mainProgram;
              type = "Application";
              icon = "io.github.hedge_dev.hedgemodmanager";
              desktopName = "Hedge Mod Manager";
              comment = meta.description;
              categories = ["Game"];
              startupWMClass = meta.mainProgram;
              mimeTypes = [
                "x-scheme-handler/hedgemm"
                "x-scheme-handler/hedgemmswa"
                "x-scheme-handler/hedgemmgens"
                "x-scheme-handler/hedgemmlw"
                "x-scheme-handler/hedgemmforces"
                "x-scheme-handler/hedgemmtenpex"
                "x-scheme-handler/hedgemmmusashi"
                "x-scheme-handler/hedgemmrainbow"
                "x-scheme-handler/hedgemmhite"
                "x-scheme-handler/hedgemmrangers"
                "x-scheme-handler/hedgemmmillersonic"
                "x-scheme-handler/hedgemmmillershadow"
              ];
              keywords = [
                "hedgehog"
                "mod"
                "loader"
                "manager"
                "sonic"
              ];
            })
          ];

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
