{
  options = { lib, pkgs, ... }:
    let types = lib.types;
    in {
      options.git = {
        enable = lib.mkEnableOption "Enable los Git";

        withLfs = lib.mkOption {
          description = "Enable Git LFS support";
          type = types.bool;
          default = false;
        };

        username = lib.mkOption {
          description = "Git username (defaults to system username if null)";
          type = types.nullOr types.str;
          default = null;
        };

        email = lib.mkOption {
          description = "Git email";
          type = types.nullOr types.str;
          default = null;
        };

        editor = {
          package = lib.mkOption {
            description = "Nix package for git $EDITOR program";
            type = types.package;
            default = pkgs.helix;
          };

          binPath = lib.mkOption {
            description = "Path to executable from the derivation root of package";
            type = types.str;
            default = "bin/hx";
          };
        };
      };
    };

  config = { lib, config, pkgs, ... }:
    let
      homev2 = import ../lib.nix { inherit lib; };
    in {
      config.home-manager.users = homev2.mkConfigPerUser config (username: userCfg:
        lib.mkIf userCfg.git.enable (
          let
            cfg = userCfg.git;
            editor = cfg.editor;
            gitUsername = if cfg.username != null then cfg.username else username;
            gitEmail = if cfg.email != null then cfg.email else "${username}@${config.networking.hostName}";
          in
          {
            home.sessionVariables = {
              EDITOR = "${editor.package.outPath}/${editor.binPath}";
            };

            programs = {
              ${editor.package.pname}.enable = true;

              git = {
                enable = true;
                lfs.enable = cfg.withLfs;
                settings.user = {
                  name = gitUsername;
                  email = gitEmail;
                  push = {
                    autoSetupRemote = true;
                  };
                };
              };
            };
          }
        )
      );
    };
}
