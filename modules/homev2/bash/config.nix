# Bash config module

{ lib, config, inputs, ... }:

let
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt-standalone.bash";

in
{
  config.home-manager.users = lib.mapAttrs (username: userCfg:
    lib.mkIf userCfg.bash.enable {
      programs.bash = {
        enable = true;
        enableCompletion = true;

        historyControl = [ "ignoreboth" ];
        historyFile = null;
        historySize = 256;

        shellAliases = {
          ".." = "cd ..";
          "c" = "clear";
          "e" = "exit";
          "g" = "git";
          "ga" = "git add";
          "gc" = "git commit";
          "gs" = "git status";
          "gp" = "git push";
          "h" = "hx";
        };

        initExtra = ''
          . ${prompt};
        '';
      };
    }
  ) config.los.homev2;
}

