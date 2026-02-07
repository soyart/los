{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.mkPerUserConfig config (username: userCfg:
    lib.mkIf userCfg.helix.enable (
      let cfg = userCfg.helix; in
      {
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
    )
  );
}

