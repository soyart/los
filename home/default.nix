{ inputs, pkgsFor, ... }:

let
  inherit (inputs) home-manager;

  mkHome =
    { modules
    , username
    , stateVersion ? "24.05"
    , system ? "x86_64-linux"
    ,
    }: home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;

      inherit modules;
      extraSpecialArgs = { inherit inputs username stateVersion; };
    };
in
{
  "artnoi@los-t14" = mkHome rec {
    username = "artnoi";
    modules = [
      ({ inputs, ... }: {
        config.home-manager = {
          extraSpecialArgs = { inherit inputs; };
        };
      })

      (import ../presets/sway-dev username)
    ];
  };
}
