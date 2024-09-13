username:

{ ... }:

{
  home-manager.users."${username}".programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";
      keyboard.bindings = [
        {
          action = "Paste";
          key = "V";
          mods = "Command";
        }
        {
          action = "Paste";
          key = "C";
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
}
