{ lib, config, pkgs, ... }:

let
  liblos = import ../liblos { inherit lib pkgs; };
  types = lib.types;
  cfg = config.los.syspkgs;

in
{
  options.los.syspkgs = lib.mkOption {
    type = types.listOf types.path;
    description = "List of los package paths (text files whose line is a Nixpkgs package). The values will be assigned to environment.systemPackages";
    default = [ ];
    example = [ ../packages/base.txt ];
  };

  config = {
    environment.systemPackages = lib.lists.flatten (builtins.map liblos.import-txt cfg);
  };
}
