# VSCodium submodule options for los.homev2.<user>

{ lib, pkgs, ... }:

{
  options.vscodium = {
    enable = lib.mkEnableOption "Enable VSCodium module, with Nix support";
    fhs = lib.mkEnableOption "Use FHS-compatible VSCodium package";
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.vscode-extensions; [
        golang.go
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
      ];
      example = "with pkgs.vscode-extensions; [ golang.go jnoortheen.nix-ide rust-lang.rust-analyzer ]";
    };
  };
}

