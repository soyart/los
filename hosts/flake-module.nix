{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  nixosConfigurations = import ./default.nix { inherit inputs; };

  # Example usage: `nix build .#homeFiles.los-t14.artnoi`
  # Outputs will land under result/home-files/
  mkHomeFiles =
    _hostName: nixos:
    lib.genAttrs
      (map (u: u.username) nixos.config.los.users)
      (username: nixos.config.home-manager.users.${username}.home.activationPackage);
in
{
  flake = {
    inherit nixosConfigurations;
    homeFiles = lib.mapAttrs mkHomeFiles nixosConfigurations;
  };
}
