{ lib, pkgs, config, inputs, ... }:

let
  prompt = "${inputs.unix}/dotfiles/pkg/shell/.config/shell/prompt/prompt.zsh";
  anyZshEnabled = lib.any (cfg: (cfg.zsh or { }).enable or false) (lib.attrValues config.los.homev2);

in
{
  # NixOS system config for availability
  config = {
    programs.zsh.enable = lib.mkIf anyZshEnabled true;
    users.users = lib.mapAttrs
      (username: cfg:
        lib.mkIf cfg.zsh.enable {
          shell = pkgs.zsh;
        }
      )
      config.los.homev2;
  };

  # HomeManager defines actual Zsh config
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

