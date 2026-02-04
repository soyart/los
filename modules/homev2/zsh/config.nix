{ lib, config, inputs, ... }:

let
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt.zsh";

in
{
  config.home-manager.users = lib.mapAttrs
    (username: cfg:
      lib.mkIf cfg.zsh.enable {
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
    )
    config.los.homev2;
}

