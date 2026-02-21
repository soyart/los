# Library functions for homev2 modules
#
# Design philosophy: Provide simple primitives and let callers compose them.
# Enable checks are explicit at call sites for clarity and flexibility.
#
# Usage:
#   { lib, config, ... }:
#   let homev2 = import ./lib.nix { inherit lib; };
#   in {
#     users.users = homev2.mkConfigPerUser config (username: userCfg:
#       lib.mkIf userCfg.zsh.enable {
#         shell = pkgs.zsh;
#       }
#     );
#   }

{ lib }:

rec {
  # Core function: Map over all users in config.los.homev2
  #
  # Args:
  #   config: The full NixOS config
  #   mkConfig: Function (username, userCfg) => config attrset
  #
  # Returns: attrset mapping usernames to their configs
  #
  # Example:
  #   mkConfigPerUser config (username: userCfg: { home.stateVersion = "24.05"; })
  mkConfigPerUser = config: mkConfig:
    lib.mapAttrs mkConfig config.los.homev2;

  # Check if ANY user has a specific module enabled
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name to check
  #
  # Returns: boolean
  #
  # Example:
  #   lib.mkIf (anyEnabled config "firefox") { environment.pathsToLink = [...]; }
  anyEnabled = config: module:
    lib.any
      (userCfg: userCfg.${module}.enable)
      (lib.attrValues config.los.homev2);

  # Get attrset of users who have a specific module enabled
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name to filter by
  #
  # Returns: attrset of filtered users
  #
  # Example:
  #   lib.mapAttrs (username: _: { extraGroups = ["video"]; }) (getEnabledUsers config "sway")
  getEnabledUsers = config: module:
    lib.filterAttrs
      (username: userCfg: userCfg.${module}.enable)
      config.los.homev2;

  # Map over enabled users and return a list
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name to filter by
  #   fn: Function (username, userCfg) => result
  #
  # Returns: list of results for users where module is enabled
  #
  # Example:
  #   mapEnabledUsers config "sway" (username: _: { inherit username; cmd = "..."; })
  mapEnabledUsers = config: module: fn:
    lib.mapAttrsToList fn (getEnabledUsers config module);

  # Declare per-user options for los.homev2
  #
  # Wraps submodule option modules in the mkOption/attrsOf/submoduleWith
  # boilerplate. Multiple modules can each call this independently --
  # NixOS merges submoduleWith types by concatenating their module lists.
  #
  # Args:
  #   pkgs: The nixpkgs package set (passed as specialArgs to submodules)
  #   modules: List of NixOS modules defining per-user options
  #
  # Returns: mkOption value suitable for options.los.homev2
  #
  # Example:
  #   options.los.homev2 = homev2.mkPerUserOptions pkgs [
  #     ({ lib, ... }: { options.git.enable = lib.mkEnableOption "Enable Git"; })
  #   ];
  mkPerUserOptions = pkgs: modules: lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      specialArgs = { inherit pkgs; };
      inherit modules;
    });
    default = { };
  };
}
