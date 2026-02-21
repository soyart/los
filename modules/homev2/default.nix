# Central definition for attrsOf-based per-user modules (los.homev2)
#
# This module defines los.homev2 with a submodule that includes options
# from all per-user modules. Each module contributes its options via
# the submoduleWith pattern.
#
# Modules are auto-discovered from sibling directories. Two styles:
#
#   Split (legacy): directory has options.nix + config.nix
#     options.nix is fed into the central submoduleWith, config.nix imported
#
#   Unified: directory has default.nix (no options.nix)
#     default.nix is an attrset { options, config } -- both NixOS modules
#     Central module extracts .options into submoduleWith, .config into imports
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
  entries = builtins.readDir ./.;
  moduleDirs = lib.filterAttrs (name: type: type == "directory") entries;

  hasSplitFiles = name:
    let dir = builtins.readDir ./${name};
    in dir ? "options.nix" && dir ? "config.nix";

  # Split modules: options fed to submoduleWith, config imported as NixOS module
  splitDirs = lib.filterAttrs (name: _: hasSplitFiles name) moduleDirs;
  optionsModules = lib.mapAttrsToList (name: _: ./${name}/options.nix) splitDirs;
  configModules = lib.mapAttrsToList (name: _: ./${name}/config.nix) splitDirs;

  # Unified modules: attrsets with { options, config } extracted separately
  unifiedDirs = lib.filterAttrs (name: _: !(hasSplitFiles name)) moduleDirs;
  unifiedModules = lib.mapAttrsToList (name: _: import ./${name}) unifiedDirs;
  unifiedOptions = map (m: m.options) unifiedModules;
  unifiedConfigs = map (m: m.config) unifiedModules;

in
{
  options.los.homev2 = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      specialArgs = { inherit pkgs; };
      modules = optionsModules ++ unifiedOptions;
    });
    default = { };
    description = "Per-user configuration (attrsOf-based modules)";
  };

  imports = configModules ++ unifiedConfigs;
}
