username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.homev1."${username}".helix;

in
{
  options = {
    los.homev1."${username}".helix = {
      enable = lib.mkEnableOption "Enable Helix editor from los";
      langServers = lib.mkOption {
        description = "List of LSP Nix packages only available to Helix";
        type = types.listOf types.package;
        default = [ ];
        example = with pkgs; [
          gopls
          marksman
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.helix = {
        enable = true;

        extraPackages = lib.mkIf ((builtins.length cfg.langServers) != 0)
          cfg.langServers;

        settings = {
          theme = "catppuccin_macchiato";
          editor = import ./editor.nix;
          keys = import ./keys.nix;
        };

        languages = import ./languages.nix pkgs;
      };
    };
  };
}

