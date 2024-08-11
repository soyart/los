{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  # inherit (inputs.disko.nixosModules) disko;
  # inherit (inputs.sops-nix.nixosModules) sops;

  mkHost =
    { modules
    , mainUser
    , hostname ? "los"
    , stateVersion ? "23.11"
    , system ? "x86_64-linux"
    , # disk ? ./disks/thinkpad.nix,
    }: nixosSystem {
      inherit system modules;

      specialArgs = {
        inherit hostname mainUser inputs stateVersion;
      };

      # modules = [ sops disko ./shared ] ++ modules; 
      # specialArgs = { inherit inputs disk stateVersion; };
    };

  # Imports home-manager as NixOS modules,
  # and with defaults home-manager.home config.
  withDefaultHomeManager = { inputs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    config.home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
    };
  };

in
{
  "los-t14" =
    let username = "artnoi";
    in mkHost {
      hostname = "los-t14";
      mainUser = username;

      modules = [
        ./hosts/t14
        withDefaultHomeManager

        (import ../../presets/sway-dev username)
        (import ../../defaults/devel-gui/vscodium.nix username)
      ];
    };
}
