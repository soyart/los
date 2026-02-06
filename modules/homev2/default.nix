# Central definition for attrsOf-based per-user modules (los.homev2)
#
# This module defines los.homev2 with a submodule that includes options
# from all per-user modules. Each module contributes its options via
# the submoduleWith pattern.
#
# Modules are auto-discovered from sibling directories. Each directory
# must contain options.nix and config.nix files.
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2 = {
#     alice = {
#       languages.go.enable = true;
#       sway.enable = true;
#       firefox.enable = true;
#     };
#     bob = {
#       languages.rust.enable = true;
#       git.enable = true;
#     };
#   };

{ lib, pkgs, ... }:

let
  # Get all entries in this directory
  entries = builtins.readDir ./.;

  # Filter for directories only (these are the module directories)
  moduleDirs = lib.filterAttrs (name: type: type == "directory") entries;

  # Build list of options.nix paths
  optionsModules = lib.mapAttrsToList (name: _: ./${name}/options.nix) moduleDirs;

  # Build list of config.nix paths
  configModules = lib.mapAttrsToList (name: _: ./${name}/config.nix) moduleDirs;

in
{
  options.los.homev2 = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      specialArgs = { inherit pkgs; };
      modules = optionsModules;
    });
    default = { };
    description = "Per-user configuration (attrsOf-based modules)";
  };

  imports = configModules;
}
