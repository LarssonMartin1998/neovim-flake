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
              rev = "e71d2c817d1a2475551f58a98e411f6b39a5be3f";
              sha256 = "0wzhs3i0kyrnl7k5y8kfhnhb1vyskwrax6ry5frk2zlpj8qivbhd";
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
