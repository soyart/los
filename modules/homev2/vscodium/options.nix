# VSCodium submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.vscodium = {
    enable = lib.mkEnableOption "Enable VSCodium module, with Nix support";
    fhs = lib.mkEnableOption "Use FHS-compatible VSCodium package";
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "VSCode extensions to install (defaults to go, nix-ide, rust-analyzer)";
    };
  };
}
