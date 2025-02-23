{
  description = "Custom Neovim Build from Specific Commit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
            pname = "neovim";
            version = "v0.11.0-dev";

            src = prev.fetchgit {
              url = "https://github.com/neovim/neovim.git";
              rev = "b288fa8d62c3f129d333d3ea6abc3234039cad37";
              sha256 = "ta3rq+pr6YxLvSiU4ydDvq79z1w+L0Ozmq0b9Cv5sn8=";
            };

            buildInputs = oldAttrs.buildInputs ++ [ final.utf8proc ];

            patches = [
              ./reuse_win-focus.patch
            ];

            installCheckPhase = "";
          });
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          neovim = pkgs.neovim;
        };

        apps = {
          neovim = flake-utils.lib.mkApp {
            drv = self.packages.${system}.neovim;
          };
        };
      }
    );
}
