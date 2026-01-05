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

{ lib, ... }:

{
  options.los.homev2 = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      modules = [
        ./devel/options.nix
        ./fonts/options.nix
        ./sway/options.nix
        ./firefox/options.nix
        ./git/options.nix
        ./helix/options.nix
        ./lf/options.nix
        ./vscodium/options.nix
      ];
    });
    default = {};
    description = "Per-user configuration (attrsOf-based modules)";
  };

  # Import config modules that use los.homev2
  imports = [
    ./devel/config.nix
    ./fonts/config.nix
    ./sway/config.nix
    ./firefox/config.nix
    ./git/config.nix
    ./helix/config.nix
    ./lf/config.nix
    ./vscodium/config.nix
  ];
}
