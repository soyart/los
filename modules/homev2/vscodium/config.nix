{ lib, config, pkgs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  nixd = "${pkgs.nixd}/bin/nixd";
  nixfmt = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
in
{
  config.home-manager.users = homev2.forEachEnabled config "vscodium" (username: cfg: {
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
  });
}

