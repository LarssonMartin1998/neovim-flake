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
            version = "v0.11.1-dev";

            src = prev.fetchgit {
              url = "https://github.com/neovim/neovim.git";
              rev = "b5158e8e92fbb8206c620961b5b330b90b34429b";
              sha256 = "0xwiddwqhpmc032fybszgsgm34pbfm26l86pz8kikvxvsh6a9wsn";
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
