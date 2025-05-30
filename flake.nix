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
            version = "v0.11.2";

            src = prev.fetchgit {
              url = "https://github.com/neovim/neovim.git";
              rev = "a73904168a";
              sha256 = "pNiljEtBNn2nfvtqa+R1nwrqcaGGFKvRh00ciGYN/pM=";
            };

            buildInputs = oldAttrs.buildInputs ++ [ final.utf8proc ];

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
