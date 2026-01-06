# Languages submodule options for los.homev2.<user>
#
# This file is imported by modules/homev2/default.nix as part of
# the submoduleWith definition. It only defines options, no config.

{ lib, ... }:

let
  types = lib.types;

  langSubmodule = {
    options.enable = lib.mkEnableOption "Enable this language for the user";
  };

in
{
  options.languages = lib.mkOption {
    description = ''
      Programming languages to be made available to the user's shell.
    '';
    type = types.attrsOf (types.submodule langSubmodule);
    default = {};
  };
}

