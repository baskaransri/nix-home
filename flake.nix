{
  description = "Home Manager NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    homeConfigurations = {
      baskaran = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-darwin";
        homeDirectory = "/home/baskaran";
        username = "baskaran";
        stateVersion = "21.05";
        configuration = { config, pkgs, ... }:
          let
            overlay-unstable = final: prev: {
              unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-darwin;
            };
          in {
            nixpkgs.overlays = [ overlay-unstable ];
            nixpkgs.config = {
              allowUnfree = true;
              allowBroken = true;
            };

            imports = [ ./users/baskaran/.config/nixpkgs/home.nix ];
          };
      };
    };
    baskaran = self.homeConfigurations.baskaran.activationPackage;
    defaultPackage.x86_64-darwin = self.baskaran;
  };
}
