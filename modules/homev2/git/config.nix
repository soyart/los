# Git config module

{ lib, config, pkgs, ... }:

{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    let
      cfg = userCfg.git;
      editorPkg = if cfg.editor.package != null then cfg.editor.package else pkgs.helix;
      # Use provided username/email or fallback to system username/hostname
      gitUsername = if cfg.username != null then cfg.username else username;
      gitEmail = if cfg.email != null then cfg.email else "${username}@${config.networking.hostName}";
    in
    lib.mkIf cfg.enable {
      home.sessionVariables = {
        EDITOR = "${editorPkg.outPath}/${cfg.editor.binPath}";
      };

      programs = {
        ${editorPkg.pname}.enable = true;

        git = {
          enable = true;
          lfs.enable = cfg.withLfs;
          userName = gitUsername;
          userEmail = gitEmail;
          extraConfig = {
            push.autoSetupRemote = true;
          };
        };
      };
    }
  ) config.los.homev2;
}
