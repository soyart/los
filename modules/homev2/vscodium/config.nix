# VSCodium config module

{ lib, config, pkgs, ... }:

let
  nixd = "${pkgs.nixd}/bin/nixd";
  nixfmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

in
{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      cfg = userCfg.vscodium;
    in
    lib.mkIf cfg.enable {
      programs.vscode = {
        enable = true;
        package =
          if cfg.fhs
          then pkgs.vscodium.fhs
          else pkgs.vscodium;

        profiles.default = {
          extensions = cfg.extensions;
          userSettings = {
            nix = {
              enableLanguageServer = true;
              serverPath = nixd;
              formatterPath = nixfmt;
              formatOnSave = true;
            };
          };
        };
      };
    }
  ) config.los.homev2;
}

