# flake.nix
{
  description = "Custom Neovim Build from Specific Commit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Using nixpkgs unstable
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs with the desired system
        pkgs = import nixpkgs { inherit system; };

        # Override neovim-unwrapped to use a specific commit
        customNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
          pname = "neovim";
          version = "custom"; # Optional: update version for clarity

          src = pkgs.fetchFromGitHub {
            owner = "neovim";
            repo = "neovim";
            rev = "7c00e0efbb18e8627ac59eaadf564a9f1b2bafcd"; # Your commit hash
            sha256 = "sha256-szhc6apRtIamuWfqi0tXjbj6HSQtNbctD9wMXbdQWcU=";
          };
        });

        # Override the neovim wrapper to use the custom neovim-unwrapped
        customNeovim = pkgs.neovim.override {
          neovim-unwrapped = customNeovimUnwrapped;
        };
      in {
        packages = {
          neovim = customNeovim;
        };

        # Optionally, define an app for easier access
        apps = {
          neovim = flake-utils.lib.mkApp {
            drv = self.packages.${system}.neovim;
          };
        };
      }
    );
}
