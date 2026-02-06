# Library functions for homev2 modules
#
# These helpers abstract the common pattern of mapping over config.los.homev2
# to generate per-user configurations for home-manager, system users, etc.
#
# Usage in config.nix files:
#   { lib, config, ... }:
#   let homev2 = import ./lib.nix { inherit lib; };
#   in {
#     config.home-manager.users = homev2.mkConfigHome {
#       inherit config;
#       module = "zsh";
#       mkConfig = userCfg: { programs.zsh.enable = true; };
#     };
#   }

{ lib }:

rec {
  # Core mapping function - maps over all users in config.los.homev2
  #
  # Args:
  #   config: The full NixOS config
  #   fn: Function that takes (username, userCfg) and returns config
  #
  # Returns: attrset mapping usernames to their configs
  #
  # Example:
  #   mapUsers config (username: userCfg: { home.stateVersion = "24.05"; })
  mapUsers = config: fn:
    lib.mapAttrs fn config.los.homev2;

  # Map over users, applying config only if a specific module is enabled
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name (e.g., "zsh", "git", "sway")
  #   mkConfig: Function that takes userCfg and returns config
  #
  # Returns: attrset with configs for users where module is enabled
  #
  # Example:
  #   mkConfigHome { inherit config; module = "zsh"; mkConfig = userCfg: {...}; }
  mkConfigHome = { config, module, mkConfig }:
    lib.mapAttrs
      (username: userCfg:
        lib.mkIf userCfg.${module}.enable (mkConfig userCfg)
      )
      config.los.homev2;

  # Like mkConfigHome but for system-level user configurations
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name
  #   mkConfig: Function that takes userCfg and returns user config
  #
  # Example:
  #   mkConfigSystem { inherit config; module = "zsh"; mkConfig = cfg: { shell = pkgs.zsh; }; }
  mkConfigSystem = { config, module, mkConfig }:
    lib.mapAttrs
      (username: userCfg:
        lib.mkIf userCfg.${module}.enable (mkConfig userCfg.${module})
      )
      config.los.homev2;

  # Map over only the users who have a specific module enabled
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name to filter by
  #   fn: Function that takes (username, userCfg) and returns result
  #
  # Returns: list of results for filtered users
  #
  # Example:
  #   mapEnabledUsers config "sway" (username: userCfg: { inherit username; cmd = "..."; })
  mapEnabledUsers = config: module: fn:
    let
      filtered = lib.filterAttrs
        (username: userCfg: userCfg.${module}.enable)
        config.los.homev2;
    in
    lib.mapAttrsToList fn filtered;

  # Get only the users who have a specific module enabled
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name to filter by
  #
  # Returns: attrset of filtered users
  #
  # Example:
  #   let swayUsers = getEnabledUsers config "sway";
  getEnabledUsers = config: module:
    lib.filterAttrs
      (username: userCfg: userCfg.${module}.enable)
      config.los.homev2;

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

  # Check if ANY user has a module enabled using a custom predicate
  #
  # Args:
  #   config: The full NixOS config
  #   pred: Predicate function that takes userCfg and returns bool
  #
  # Returns: boolean
  #
  # Example:
  #   anyMatch config (cfg: (cfg.zsh or {}).enable or false)
  anyMatch = config: pred:
    lib.any pred (lib.attrValues config.los.homev2);

  # Simple wrapper for the most common case: home-manager config with enable check
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name
  #   mkConfig: Function that takes (username, userCfg) and returns config
  #
  # Example:
  #   forEachUser config "alacritty" (username: userCfg: { programs.alacritty = {...}; })
  forEachUser = config: module: mkConfig:
    lib.mapAttrs
      (username: userCfg:
        lib.mkIf userCfg.${module}.enable (mkConfig username userCfg)
      )
      config.los.homev2;

  # Like forEachUser but provides access to module config directly
  #
  # Args:
  #   config: The full NixOS config
  #   module: The module name
  #   mkConfig: Function that takes (username, moduleCfg) and returns config
  #
  # Example:
  #   forEachEnabled config "git" (username: gitCfg: { programs.git.userName = gitCfg.username; })
  forEachEnabled = config: module: mkConfig:
    lib.mapAttrs
      (username: userCfg:
        lib.mkIf userCfg.${module}.enable (mkConfig username userCfg.${module})
      )
      config.los.homev2;

  # Map without automatic enable check - useful when you need custom conditions
  #
  # Args:
  #   config: The full NixOS config
  #   mkConfig: Function that takes (username, userCfg) and returns config
  #
  # Example:
  #   forAll config (username: userCfg: lib.mkIf (userCfg.git.enable && userCfg.helix.enable) {...})
  forAll = config: mkConfig:
    lib.mapAttrs mkConfig config.los.homev2;
}
