{ lib, config, ... }:

let
  types = lib.types;
  cfg = config.los.ramDisks;

in
{
  options.los.ramDisks = lib.mkOption {
    description = "Set of tmpfs mounts";
    type = types.attrsOf (types.submodule {
      options = {
        perm = lib.mkOption {
          type = types.str;
          default = "755";
        };
        owner = lib.mkOption {
          type = types.str;
          default = "root";
        };
        group = lib.mkOption {
          type = types.str;
          default = "root";
        };
        size = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    });
    example = {
      "/rd1" = { };
      "/rd2".size = "500M";
      "/rd2".owner = "userfoo";
      "/rd3" = {
        size = "1G";
        perm = "744";
      };
    };
  };

  config =
    let
      mapFn = key: value:
        let
          mntOpts = [
            "defaults"
            "mode=${value.perm}"
            "uid=${value.owner}"
            "gid=${value.group}"
          ]
          ++ lib.optional (value.size != null) "size=${value.size}";

        in
        {
          device = "none";
          fsType = "tmpfs";
          options = mntOpts;
        };

    in
    {
      # Nix module system will merge this to global config.fileSystems
      fileSystems = builtins.mapAttrs mapFn cfg;
    };
}
