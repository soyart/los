# Flake "module" for flake-parts

{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  nixosConfigurations = import ./default.nix { inherit inputs; };

  # Example usage: `nix build .#homeFiles.los-t14.artnoi`
  # home-manager outputs will land under ./result/home-files (default location set from home-manager)
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
