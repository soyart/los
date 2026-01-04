{ lib, pkgs }:

let
  files = builtins.readDir ./.;
  nixFiles = lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
    files;
  toAttrName = filename: lib.removeSuffix ".nix" filename;
  importFile = filename: import (./. + "/${filename}") { inherit lib pkgs; };
in

# Map each imported file to its base name (without .nix extension)
lib.mapAttrs' (name: _: lib.nameValuePair (toAttrName name) (importFile name)) nixFiles

