{ lib, pkgs, config, inputs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt.zsh";
  promptGit = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt-git.sh";
in
{
  config.los.homev2Modules = [
    ({ lib, ... }: {
      options.zsh.enable = lib.mkEnableOption "Enable ZSh shell with los defaults";
    })
  ];

  config.programs.zsh.enable = homev2.anyEnabled config "zsh";

  config.users.users = homev2.mkConfigPerUser config (username: userCfg:
    lib.mkIf userCfg.zsh.enable {
      shell = pkgs.zsh;
    }
  );

  config.home-manager.users = homev2.mkConfigPerUser config (username: userCfg:
    lib.mkIf userCfg.zsh.enable {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history.size = 256;

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

        initContent = ''
          . ${promptGit};
          . ${prompt};
        '';
      };
    }
  );
}
