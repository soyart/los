# Helix submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.helix = {
    enable = lib.mkEnableOption "Enable Helix editor from los";
    langServers = lib.mkOption {
      description = "List of LSP Nix packages only available to Helix";
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };
}

