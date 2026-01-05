{ lib, pkgs, config, ... }:

let
  liblos = import ../../liblos { inherit lib pkgs; };
  constants = import ../../liblos/constants.nix;
  types = lib.types;
  cfg = config.los;
  
  inherit (constants.groups) defaultUserGroup;

  allUsernames = map (u: u.username) cfg.users;
  superusers = builtins.filter (u: u.superuser) cfg.users;
  superuserNames = map (u: u.username) superusers;

  # Illegal group names
  illegalGroups = [ "root" "wheel" ];
  hasIllegalGroup = groups: builtins.any (g: builtins.elem g illegalGroups) groups;

  userSubmodule = types.submodule {
    options = {
      username = lib.mkOption {
        type = liblos.extend {
          base = types.str;
          check = (s: s != "root");
        };
        description = "Username (cannot be 'root')";
      };

      superuser = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Whether this user is a superuser (wheel + doas access)";
      };

      hashedPassword = lib.mkOption {
        type = liblos.extend {
          base = types.str;
          check = (s: s != "");
        };
        description = "Hashed password (required, cannot be empty)";
      };

      homeStateVersion = lib.mkOption {
        type = types.str;
        description = "Home Manager stateVersion for this user";
        example = "24.05";
      };

      extraGroups = lib.mkOption {
        type = liblos.extend {
          base = types.nullOr (types.listOf types.str);
          check = (groups: groups == null || !hasIllegalGroup groups);
        };
        default = null;
        description = "Extra groups (cannot contain 'root' or 'wheel')";
        example = [ "video" "docker" ];
      };
    };
  };

in
{
  options.los.users = lib.mkOption {
    type = types.listOf userSubmodule;
    default = [];
    description = "System users (set superuser = true for wheel + doas access)";
  };

  config = lib.mkIf (cfg.users != []) {
    # Groups: shared defaultUserGroup + personal group per user
    users.groups = {
      ${defaultUserGroup}.members = allUsernames;
    } // lib.listToAttrs (map (u: {
      name = u.username;
      value.members = [ u.username ];
    }) cfg.users);

    # Create all users
    users.users = lib.listToAttrs (map (u: {
      name = u.username;
      value = {
        isNormalUser = true;
        home = "/home/${u.username}";
        createHome = true;
        hashedPassword = u.hashedPassword;
        extraGroups = (if u.extraGroups == null then [] else u.extraGroups)
          ++ [ defaultUserGroup ]
          ++ lib.optional u.superuser "wheel";
      };
    }) cfg.users);

    # Doas for superusers (with mkDefault so hosts can override)
    los.doas = lib.mkIf (superusers != []) {
      enable = lib.mkDefault true;
      settings.users = lib.mkDefault superuserNames;
    };

    # Home Manager skeleton for each user
    home-manager.users = lib.listToAttrs (map (u: {
      name = u.username;
      value = {
        home.stateVersion = u.homeStateVersion;
      };
    }) cfg.users);
  };
}

