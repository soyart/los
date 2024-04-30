
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: with nixpkgs.lib; {
    nixosConfigurations."nexpr-t14" = nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
      ];
    };
  };
}
