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
                # Define an overlay to override neovim-unwrapped
                overlay = final: prev: {
                    neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
                        pname = "neovim";
                        version = "v0.11.0-dev"; # Optional: update version for clarity

                        src = prev.fetchgit {
                            url = "https://github.com/neovim/neovim.git";
                            rev = "7c00e0efbb18e8627ac59eaadf564a9f1b2bafcd"; # Your commit hash
                            sha256 = "1iara2vms36w1wnvfd9d4hfzmf4dax5qpsk7p6k8dd2imblmqf5k"; # Correct sha256
                        };

                        buildInputs = oldAttrs.buildInputs ++ [ final.utf8proc ];

                        installCheckPhase = "";
                    });
                };

                # Import nixpkgs with the overlay
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ overlay ];
                };
            in {
                packages = {
                    neovim = pkgs.neovim;
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
