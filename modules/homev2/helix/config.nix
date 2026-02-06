{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.forEachEnabled config "helix" (username: cfg: {
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
  });
}

