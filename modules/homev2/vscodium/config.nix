# VSCodium config module

{ lib, config, pkgs, ... }:

let
  nixd = "${pkgs.nixd}/bin/nixd";
  nixfmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

  defaultExtensions = with pkgs.vscode-extensions; [
    golang.go
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
  ];

in
{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      cfg = userCfg.vscodium;
      extensions = if cfg.extensions == [] then defaultExtensions else cfg.extensions;
    in
    lib.mkIf cfg.enable {
      programs.vscode = {
        enable = true;
        package =
          if cfg.fhs
          then pkgs.vscodium.fhs
          else pkgs.vscodium;

        profiles.default = {
          inherit extensions;
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
