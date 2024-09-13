{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.syspkgs;
  importTxt = import ../liblos/import-txt.nix { inherit pkgs; };

in
{
  options.los.syspkgs = lib.mkOption {
    type = types.listOf types.path;
    description = "List of los package paths (text files whose line is a Nixpkgs package). The values will be assigned to environment.systemPackages";
    default = [ ];
    example = [ ../packages/base.txt ];
  };

  config = {
    environment.systemPackages = lib.lists.flatten (builtins.map (p: importTxt p) cfg);
  };
}
