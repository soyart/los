{ lib, config, inputs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt-standalone.bash";
in
{
  config.home-manager.users = homev2.mkConfigPerUser config (username: userCfg:
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
  );
}

