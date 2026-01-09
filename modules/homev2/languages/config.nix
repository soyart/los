# Languages config module
#
# This file is imported by modules/homev2/default.nix.
# It reads los.homev2 and sets home-manager.users accordingly.

{ lib, config, pkgs, ... }:

let
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

in
{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      enabledLangs = lib.filterAttrs (name: lang: lang.enable) userCfg.languages;
      packages = lib.flatten (lib.mapAttrsToList (name: _: mappings.${name} or []) enabledLangs);
    in
    lib.mkIf (packages != []) {
      home.packages = packages;
    }
  ) config.los.homev2;
}

