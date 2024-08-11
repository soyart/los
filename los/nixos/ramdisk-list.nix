{ lib, config, ... }:

let
  types = lib.types;
  cfg = config.los.ramDiskList;

in
{
  options.los.ramDiskList = lib.mkOption {
    description = "List of tmpfs mounts";
    type = types.listOf (types.submodule {
      options = {
        mnt = lib.mkOption {
          type = types.str;
        };
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
    example = [
      { mnt = "/rd1"; }
      { mnt = "/rd2"; size = "1G"; perm = 744; }
      { mnt = "/rd3"; size = "500M"; group = "root"; }
    ];
  };

  config =
    let
      mapFn = c: {
        "${c.mnt}" = {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "mode=${cfg.perm}"
            "uid=${cfg.owner}"
            "gid=${cfg.group}"
          ]
          ++ lib.optional (cfg.size != null) "size=${cfg.size}";
        };
      };

    in
    {
      fileSystems = lib.attrsets.mergeAttrsList (map mapFn cfg);
    };
}
