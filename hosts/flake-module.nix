{ inputs, ... }:
{
  flake = {
    nixosConfigurations = import ./default.nix { inherit inputs; };
  };
}
