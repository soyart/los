username:

{ lib, pkgs, config, ... }:

let
  types = lib.types;
  cfg = config.los.homev1."${username}".vscodium;

  nixd = "${pkgs.nixd}/bin/nixd";
  nixfmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

in
{
  options = {
    los.homev1."${username}".vscodium = {
      enable = lib.mkEnableOption "Enable VSCodium module, with Nix support";
      fhs = lib.mkEnableOption "Use FHS-compatible VSCodium package";
      extensions = lib.mkOption {
        type = types.listOf types.package;

        example = with pkgs.vscode-extensions; [
          golang.go
          jnoortheen.nix-ide
          rust-lang.rust-analyzer
        ];

        # https://search.nixos.org/packages?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=vscode-extensions
        default = with pkgs.vscode-extensions; [
          golang.go
          jnoortheen.nix-ide
          rust-lang.rust-analyzer
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
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
    };
  };
}

