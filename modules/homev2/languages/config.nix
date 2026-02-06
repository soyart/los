{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  
  mappings = {
    go = with pkgs; [
      go
      gopls
      gcc
    ];

    rust = with pkgs; [
      cargo
      rustfmt
      rust-analyzer
    ];
  };
in
{
  config.home-manager.users = homev2.forAll config (username: userCfg:
    let
      enabledLangs = lib.filterAttrs (name: lang: lang.enable) userCfg.languages;
      packages = lib.flatten (lib.mapAttrsToList (name: _: mappings.${name} or [ ]) enabledLangs);
    in
    {
      home.packages = packages;
    }
  );
}

