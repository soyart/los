# Helix config module

{ lib, config, pkgs, ... }:

{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      cfg = userCfg.helix;
    in
    lib.mkIf cfg.enable {
      programs.helix = {
        enable = true;

        extraPackages = lib.mkIf (builtins.length cfg.langServers != 0)
          cfg.langServers;

        settings = {
          theme = "catppuccin_macchiato";
          editor = import ./editor.nix;
          keys = import ./keys.nix;
        };

        languages = import ./languages.nix pkgs;
      };
    }
  ) config.los.homev2;
}

