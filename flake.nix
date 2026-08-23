{
  description = "NixOS configuration";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./ci/flake-module.nix
        ./hosts/flake-module.nix
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          packages = {
            dwmbar = pkgs.buildGoModule {
              pname = "dwmbar";
              version = "0.1.0";
              src = pkgs.fetchFromGitHub {
                owner = "soyart";
                repo = "dwmbar";
                rev = "4961f9f171663b58cfe71f73a7e9c11300cb7608";
                sha256 = "sha256-BM3+OSJDD7uuNFz1uqZHVYGkQ3aHuwHozpRuB2/7o1Q=";
              };
              vendorHash = "sha256-WUTGAYigUjuZLHO1YpVhFSWpvULDZfGMfOXZQqVYAfs=";
            };
            dmenutrackpad = pkgs.buildGoModule {
              pname = "dmenutrackpad";
              version = "0.1.0";
              src = ./src/dmenutrackpad;
              vendorHash = null;
            };
          };
        };
    };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci/3.1.2?dir=lib";

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
