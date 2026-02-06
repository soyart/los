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
    default = { };
  };
}

