{ inputs, pkgsFor, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  # inherit (inputs.disko.nixosModules) disko;
  # inherit (inputs.sops-nix.nixosModules) sops;

  mkHost =
    { modules
    , stateVersion
    , mainUsername
    , hostname ? "los"
    , system ? "x86_64-linux"
    , # disk ? ./disks/thinkpad.nix,
    }: nixosSystem {
      inherit system modules;
      pkgs = pkgsFor system;

      specialArgs = {
        inherit hostname mainUsername inputs stateVersion;
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
      stateVersion = "23.11"; # DO NOT CHANGE
      mainUsername = username;

      modules = [
        ./t14
        withDefaultHomeManager

        (import ../presets/sway-dev username)
        (import ../defaults/devel-gui/vscodium.nix username)
      ];
    };
}
