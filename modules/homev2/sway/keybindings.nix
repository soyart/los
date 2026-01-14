# Sway keybindings for homev2

{ mod, dmenutrackpad }:

{
  keybindings = {
    "${mod}+Return" = "exec alacritty";
    "${mod}+q" = "kill";
    "${mod}+r" = "mode resize";
    "${mod}+Shift+r" = "reload";
    "${mod}+Shift+q" = "exit";

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

    "${mod}+minus" = "scratchpad show";
    "${mod}+Shift+minus" = "move scratchpad";

    "${mod}+0" = "exec wofipower";
    "${mod}+t" = "exec ${dmenutrackpad}/bin/dmenutrackpad";
    "${mod}+d" = "exec wofi --show run";

    "--locked XF86AudioRaiseVolume" = "exec sndctl up";
    "--locked XF86AudioLowerVolume" = "exec sndctl dn";
    "--locked XF86AudioMute" = "exec sndctl mute";
    "--locked XF86AudioMicMute" = "exec sndctl micmute";
    "--locked XF86AudioPlay" = "exec playerctl play-pause";
    "--locked XF86AudioNext" = "exec playerctl next";
    "--locked XF86AudioPrev" = "exec playerctl previous";

    "--locked XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
    "--locked XF86MonBrightnessUp" = "exec brightnessctl set 10%+";
  };

  modes.resize =
    let
      pixels = "10px";
    in
    {
      "Return" = "mode default";
      "Escape" = "mode default";
      "h" = "resize grow height ${pixels}";
      "Down" = "resize grow height ${pixels}";
      "j" = "resize shrink width ${pixels}";
      "Left" = "resize shrink width ${pixels}";
      "k" = "resize shrink height ${pixels}";
      "Up" = "resize shrink height ${pixels}";
      "l" = "resize grow width ${pixels}";
      "Right" = "resize grow width ${pixels}";
    };
}
