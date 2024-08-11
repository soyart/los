username:

{ lib, pkgs, config, hostname, ... }:

let
  types = lib.types;
  cfg = config.los.home."${username}".progs.git;

in
{
  options = {
    los.home."${username}".progs.git = {
      enable = lib.mkEnableOption "Enable los Git";

      withLfs = lib.mkOption {
        description = "Enable Git LFS support";
        type = types.bool;
        default = false;
      };

      username = lib.mkOption {
        description = "Git username";
        type = types.str;
        default = username;
      };

      email = lib.mkOption {
        description = "Git email";
        type = types.str;
        default = "${username}@${hostname}";
      };

      editor = lib.mkOption {
        type = types.submodule {
          options.package = lib.mkOption {
            description = "Nix package to for git $EDITOR program";
            type = types.package;
            default = pkgs.helix;
          };

          options.binPath = lib.mkOption {
            description = "Path to executable from the derivation root of package";
            type = types.str // {
              check = (s: (builtins.stringLength s) != 0);
            };
            default = "bin/hx";
          };
        };
      };
    };
  };

  config = (lib.mkIf cfg.enable) {
    home-manager.users."${username}" =
      let editor = cfg.editor;

      in {
        home.sessionVariables = {
          EDITOR = "${editor.package.outPath}/${editor.binPath}";
        };

        programs = {
          ${editor.package.pname}.enable = true;

          git = {
            enable = true;
            lfs.enable = cfg.withLfs;

            userName = cfg.username;
            userEmail = cfg.email;

            extraConfig = {
              push = {
                autoSetupRemote = true;
              };
            };
          };
        };
      };
  };
}
