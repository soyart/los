username:

{ inputs, ... }:

let
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt-standalone.bash";

in
{
  home-manager.users."${username}" = {
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
  };
}
