username:

{ inputs, lib, config, ... }:

let
  colors = import ./colors.nix;
  cfg = config.los.homev1."${username}".dm.sway;
  barCommand = "${inputs.unix}/dotfiles/linux/.config/dwm/dwmbar.sh";
  wallpaper = "${inputs.self}/assets/wall/scene2.jpg";

in
{
  config.home-manager.users."${username}".wayland.windowManager.sway = lib.mkIf cfg.enable {
    enable = true;
    config = {
      startup = [
        {
          command = ''
            exec swayidle -w timeout 300 'swaylock -f -c 000000' timeout 360 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock'
          '';
          always = true;
        }
      ];

      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      terminal = "alacritty";
      gaps = {
        inner = 6;
        outer = 6;
      };

      fonts = {
        names = [ "Hack" ];
        size = 14.0;
      };

      colors = {
        focused = {
          background = "${colors.cyan}";
          border = "${colors.magenta}";
          childBorder = "${colors.cyan}";
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
            names = [ "Hack" ];
            size = 14.0;
          };

          statusCommand = "dash ${barCommand} '${username}' '${config.networking.hostName}'";

          colors = {
            background = colors.black;
            statusline = colors.blue;

            focusedWorkspace = {
              border = colors.dark0;
              background = colors.blue;
              text = colors.dark0;
            };

            inactiveWorkspace = {
              border = colors.dark0;
              background = colors.dark0;
              text = colors.blue;
            };
          };
        }
      ];
    };
  };
}

