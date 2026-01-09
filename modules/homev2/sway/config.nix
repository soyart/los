# Sway config module
#
# Note: Sway has system-level effects (pipewire, security, hardware, users.groups)
# that must be handled carefully in homev2 context.

{ lib, config, pkgs, inputs, ... }:

let
  colors = import ./colors.nix;
  scripts = import ./scripts.nix { inherit pkgs; };
  unix = inputs.unix;
  dwmbar = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".dwmbar;
  barCommand = "${dwmbar}/bin/dwmbar";
  wallpaper = "${inputs.self}/assets/wall/scene2.jpg";

  # Get usernames who have sway enabled
  swayUsers = lib.filterAttrs (username: userCfg: userCfg.sway.enable) config.los.homev2;
  anySwayEnabled = swayUsers != { };

  mod = "Mod1";
  shtools = "${inputs.unix}/sh-tools/bin";

in
{
  config = lib.mkMerge [
    # System-level config (only if ANY user has sway enabled)
    (lib.mkIf anySwayEnabled {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
      };

      security = {
        polkit.enable = true;
        rtkit.enable = true;
        pam.services.swaylock = { };
      };

      hardware.graphics.enable = true;
    })

    # Per-user doas config
    {
      los.doas.noPasswords = lib.mapAttrsToList
        (username: _: {
          inherit username;
          cmd = "${scripts.wofipower}";
        })
        swayUsers;
    }

    # Per-user groups
    {
      users.users = lib.mapAttrs
        (username: _: {
          extraGroups = [ "audio" "video" ];
        })
        swayUsers;
    }

    # Per-user home-manager config
    {
      home-manager.users = lib.mapAttrs
        (username: userCfg:
          lib.mkIf userCfg.sway.enable {
            home.packages = [
              pkgs.swayidle
              pkgs.alacritty
              pkgs.wl-clipboard
              pkgs.brightnessctl
              pkgs.dash
              pkgs.lm_sensors
              scripts.sndctl
              scripts.wofipower
            ];

            home.shellAliases = {
              "dmenu" = "wofi -d";
            };

            home.sessionVariables = {
              WAYLAND = "1";
              XDG_SESSION_TYPE = "wayland";
              XDG_CURRENT_DESKTOP = "sway";
            };

            home.file.".config/sway-bak" = {
              source = "${unix}/dotfiles/linux/.config/sway";
              recursive = true;
            };

            programs.swaylock = {
              enable = true;
              settings = {
                image = wallpaper;
                color = colors.dark1;
              };
            };

            programs.wofi = {
              enable = true;
              style = ''
                window {
                	margin: 0px;
                	border: 1px solid #a093c7;
                	background-color: #282a36;
                }

                #input {
                	margin: 5px;
                	border: none;
                	color: #f8f8f2;
                	background-color: #44475a;
                }

                #inner-box {
                	margin: 5px;
                	border: none;
                	background-color: #282a36;
                }

                #outer-box {
                	margin: 5px;
                	border: none;
                	background-color: #282a36;
                }

                #scroll {
                	margin: 0px;
                	border: none;
                }

                #text {
                	margin: 5px;
                	border: none;
                	color: #f8f8f2;
                }

                #entry:selected {
                	background-color: #44475a;
                }
              '';
            };

            wayland.windowManager.sway = {
              enable = true;
              config = {
                modifier = mod;

                startup = [
                  {
                    command = ''
                      exec swayidle -w timeout 300 'swaylock -f -c 000000' timeout 360 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock'
                    '';
                    always = true;
                  }
                ];

                output."*".bg = "${wallpaper} fill";
                terminal = "alacritty";
                gaps = { inner = 6; outer = 6; };
                fonts = { names = [ "Hack" ]; size = 14.0; };

                colors.focused = {
                  background = colors.cyan;
                  border = colors.magenta;
                  childBorder = colors.cyan;
                  text = colors.black;
                  indicator = colors.white;
                };

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
                  "${mod}+t" = "exec ${shtools}/dmenutouchpad";
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

                bars = [{
                  position = "top";
                  workspaceButtons = true;
                  workspaceNumbers = true;
                  fonts = { names = [ "Hack" ]; size = 14.0; };
                  statusCommand = barCommand;
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
                }];
              };
            };
          }
        )
        config.los.homev2;
    }
  ];
}

