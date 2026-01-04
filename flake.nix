{
  description = "NixOS configuration";

  outputs = { ... }@inputs: 
    let
      pkgsFor = system: import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      nixosConfigurations = import ./hosts { inherit inputs pkgsFor; };
    in
    {
      homeConfigurations = import ./home { inherit inputs pkgsFor; };
      inherit nixosConfigurations;

      # Extract home-manager dotfiles from NixOS builds
      dotfiles =
        let
          t14 = nixosConfigurations.los-t14.config;
          firstSuperuser = (builtins.head (builtins.filter (u: u.superuser) t14.los.users)).username;
        in
        {
          los-t14 = t14.home-manager.users.${firstSuperuser}.home.activationPackage;
        };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    unix = {
      type = "gitlab";
      owner = "artnoi";
      repo = "unix";
      ref = "master";
      flake = false;
    };
  };

  nixConfig = { };
}
