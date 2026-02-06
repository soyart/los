{ lib, config, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.forEachEnabled config "git" (username: cfg:
    let
      editor = cfg.editor;
      # Use provided username/email or fallback to system username/hostname
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
  );
}

