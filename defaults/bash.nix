username:

{ ... }:

{
  home-manager.users."${username}" = {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      historyControl = [ "ignoreboth" ];
      historyFile = null;
      historySize = 256;

      shellAliases = {
        "c" = "clear";
        "g" = "git";
        "ga" = "git add";
        "gc" = "git commit";
        "gs" = "git status";
        "h" = "hx";
      };
    };

    home.stateVersion = "24.05";
  };
}
