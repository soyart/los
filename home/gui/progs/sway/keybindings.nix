username:

{ lib, inputs, config, ... }:

let
  cfg = config.los.home."${username}".gui.progs.sway;

in
{
  config.home-manager.users."${username}".wayland.windowManager.sway = lib.mkIf cfg.enable
    {
      config.keybindings =
        let
          mod = "Mod1";
          shtools = "${inputs.unix}/sh-tools/bin";

        in
        {
          "${mod}+Return" = "alacritty";
          "${mod}+q" = "kill";
          "${mod}+Shift+r" = "reload";
          "${mod}+Shift+q" = "exit";

          "${mod}+0" = "${shtools}/dmenupower";
          "${mod}+t" = "${shtools}/dmenutouchpad";
          "${mod}+d" = "exec wofi --show run";

          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";

          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";

          "${mod}+Shift+b" = "border toggle";
          "${mod}+Shift+Space" = "border toggle all";

          "${mod}+Space" = "split toggle";
          "${mod}+Shift+s" = "floating toggle";
          "${mod}+Shift+f" = "fullscreen toggle";
          "${mod}+Shift+t" = "layout default";

          "${mod}+e" = "layout toggle split";
          "${mod}+w" = "layout tabbed";
          "${mod}+s" = "layout stacking";

          "${mod}+Tab" = "focus prev";
          "${mod}+bracketleft" = "focus prev";
          "${mod}+bracketright" = "focus next";
          "${mod}+Left" = "focus left";
          "${mod}+Right" = "focus right";
          "${mod}+Up" = "focus up";
          "${mod}+Down" = "focus down";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Show the next scratchpad window or hide the focused scratchpad window. If there are multiple scratchpad windows, this command cycles through them.
          "${mod}+minus" = "scratchpad show";
          # Move the currently focused window to the scratchpad
          "${mod}+Shift+minus" = "move scratchpad";
        };

      config.modes = {
        resize =
          let
            pixels = "10px";

            widthShrink = "resize shrink width ${pixels}";
            widthGrow = "resize grow width ${pixels}";
            heightShrink = "resize shrink height ${pixels}";
            heightGrow = "resize grow height ${pixels}";

          in
          {
            "Return" = "mode default";
            "Escape" = "mode default";

            "h" = heightGrow;
            "Down" = heightGrow;
            "j" = widthShrink;
            "Left" = widthShrink;
            "k" = heightShrink;
            "Up" = heightShrink;
            "l" = widthGrow;
            "Right" = widthGrow;
          };
      };
    };
}
