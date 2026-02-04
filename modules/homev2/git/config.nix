{ lib, config, ... }:

{
  config.home-manager.users = lib.mapAttrs
    (username: userCfg:
      let
        cfg = userCfg.git;
        editor = cfg.editor;
        # Use provided username/email or fallback to system username/hostname
        gitUsername = if cfg.username != null then cfg.username else username;
        gitEmail = if cfg.email != null then cfg.email else "${username}@${config.networking.hostName}";
      in
      lib.mkIf cfg.enable {
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
    config.los.homev2;
}

