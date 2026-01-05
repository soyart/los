{ lib, config, pkgs, ... }:

let
  types = lib.types;

  mappings = {
    go = with pkgs; [
      go
      gopls
    ];

    rust = with pkgs; [
      cargo
      rustfmt
      rust-analyzer
    ];
  };

  langSubmodule = {
    options.enable = lib.mkEnableOption "Enable this language for the user";
  };

  userDevelSubmodule = {
    options.devel = lib.mkOption {
      description = ''
        Programming languages to be made available to the user's shell.
      '';
      type = types.attrsOf (types.submodule langSubmodule);
      default = {};
    };
  };

in
{
  options.los.home = lib.mkOption {
    type = types.attrsOf (types.submodule userDevelSubmodule);
    default = {};
  };

  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      enabledLangs = lib.filterAttrs (name: lang: lang.enable) userCfg.devel;
      packages = lib.flatten (lib.mapAttrsToList (name: _: mappings.${name} or []) enabledLangs);
    in
    { home.packages = packages; }
  ) config.los.home;
}
