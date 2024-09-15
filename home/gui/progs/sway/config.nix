username:

{ inputs, lib, config, ... }:

let
  cfg = config.los.home."${username}".gui.progs.sway;
  barCommand = "${inputs.unix}/dotfiles/linux/.config/dwm/dwmbar.sh";

  colors = {
    blue = "#91acd1";
    cyan = "#95c4ce";
    green = "#c0ca8e";
    white = "#efefef";
    black = "#111111";
    sblack = "#000000";
    magenta = "#ada0d3";

    # Some colors have shades (red1/yellow1 is OpenBSD colors)
    red0 = "#e98989";
    red1 = "#cf4229";
    dark0 = "#333333";
    dark1 = "#6f6f6f";
    yellow0 = "#e9b189";
    yellow1 = "#f2ca30";
  };


in
{
  config.home-manager.users."${username}".wayland.windowManager.sway = lib.mkIf cfg.enable {
    enable = true;
    config = {
      terminal = "alacritty";
      gaps = {
        inner = 6;
        outer = 6;
      };

      colors = {
        focused = {
          background = "${colors.cyan}";
          border = "${colors.magenta}";
          childBorder = "${colors.yellow0}";
          text = "${colors.black}";
          indicator = "${colors.white}";
        };
      };

      bars = [
        {
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;

          fonts = {
            names = [ "pango:Hack" ];
            size = 14.0;
          };

          statusCommand = "dash ${barCommand} ${username} ${config.networking.hostName}'";

          colors = {
            background = colors.black;
            statusline = colors.blue;

            focusedWorkspace = {
              border = colors.dark0;
              background = colors.blue;
              text = colors.dark0;
            };

            inactiveWorkspace = {
              border = colors.blue;
              background = colors.dark0;
              text = colors.blue;
            };
          };

        }
      ];
    };
  };
}
