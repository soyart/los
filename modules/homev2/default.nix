# Central definition for attrsOf-based per-user modules (los.homev2)
#
# This module defines los.homev2 with a submodule that includes options
# from all per-user modules. Each module contributes its options via
# the submoduleWith pattern.
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2 = {
#     artnoi = {
#       devel.go.enable = true;
#       sway.enable = true;
#       firefox.enable = true;
#     };
#     bob = {
#       devel.rust.enable = true;
#       git.enable = true;
#     };
#   };

{ lib, pkgs, ... }:

{
  options.los.homev2 = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      specialArgs = { inherit pkgs; };
      modules = [
        ./alacritty/options.nix
        ./bash/options.nix
        ./languages/options.nix
        ./firefox/options.nix
        ./fonts/options.nix
        ./git/options.nix
        ./helix/options.nix
        ./lf/options.nix
        ./sway/options.nix
        ./vscodium/options.nix
      ];
    });
    default = {};
    description = "Per-user configuration (attrsOf-based modules)";
  };

  # Import config modules that use los.homev2
  imports = [
    ./alacritty/config.nix
    ./bash/config.nix
    ./languages/config.nix
    ./firefox/config.nix
    ./fonts/config.nix
    ./git/config.nix
    ./helix/config.nix
    ./lf/config.nix
    ./sway/config.nix
    ./vscodium/config.nix
  ];
}
