{ lib, pkgs, config, inputs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt.zsh";
in
{
  # NixOS system config for availability
  config = {
    programs.zsh.enable = lib.mkIf (homev2.anyEnabled config "zsh") true;

    users.users = homev2.mkPerUserConfig config (username: userCfg:
      lib.mkIf userCfg.zsh.enable {
        shell = pkgs.zsh;
      }
    );
  };

  # HomeManager defines actual Zsh config
  config.home-manager.users = homev2.mkPerUserConfig config (username: userCfg:
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
          . ${prompt};
        '';
      };
    }
  );
}

