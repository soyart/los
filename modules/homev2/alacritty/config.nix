{ lib, config, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };
in
{
  config.home-manager.users = homev2.mkConfigHome {
    inherit config;
    module = "alacritty";
    mkConfig = userCfg: {
      programs.alacritty = {
        enable = true;

        settings = {
          env.TERM = "xterm-256color";
          keyboard.bindings = [
            {
              action = "Copy";
              key = "C";
              mods = "Command";
            }
            {
              action = "Paste";
              key = "V";
              mods = "Command";
            }
          ];

          window = {
            option_as_alt = "Both";
            padding = {
              x = 4;
              y = 4;
            };
          };

          cursor.style.blinking = "Always";

          font = let fontFamily = "Hack"; in {
            offset = {
              x = 0;
              y = 0;
            };
            normal = {
              family = fontFamily;
              style = "Regular";
            };
            bold = {
              family = fontFamily;
              style = "Bold";
            };
            bold_italic = {
              family = fontFamily;
              style = "Bold Italic";
            };
            italic = {
              family = fontFamily;
              style = "Italic";
            };
          };
        };
      };
    };
  };
}

