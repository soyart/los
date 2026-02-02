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
      inherit nixosConfigurations;
      homeConfigurations = import ./home { inherit inputs pkgsFor; };

      # Linux-only packages
      packages = builtins.listToAttrs (map
        (system:
          let
            pkgs = pkgsFor system;
            dwmbar = pkgs.buildGoModule {
              pname = "dwmbar";
              version = "0.1.0";
              src = pkgs.fetchFromGitHub {
                owner = "soyart";
                repo = "dwmbar";
                rev = "0049f47989ca37a7d7038a64d53b16f92cac3e31";
                sha256 = "sha256-WOYIFlyv1Aovj40rtzXCNAzQbgpGtiwlSi7KvQ4cuPs=";
              };
              vendorHash = "sha256-WUTGAYigUjuZLHO1YpVhFSWpvULDZfGMfOXZQqVYAfs=";
            };
            dmenutrackpad = pkgs.buildGoModule {
              pname = "dmenutrackpad";
              version = "0.1.0";
              src = ./src/dmenutrackpad;
              vendorHash = null;
            };
          in
          {
            name = system;
            value = { inherit dwmbar dmenutrackpad; };
          }
        ) [ "x86_64-linux" "aarch64-linux" ]);

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
