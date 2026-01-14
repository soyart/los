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

  # Import split config files
  keys = import ./keybindings.nix { inherit mod shtools; };
  swaylockCfg = import ./swaylock.nix { inherit colors wallpaper; };
  wofiCfg = import ./wofi.nix;

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
              scripts.dmenu
              scripts.sndctl
              scripts.wofipower
            ];

            home.sessionVariables = {
              WAYLAND = "1";
              XDG_SESSION_TYPE = "wayland";
              XDG_CURRENT_DESKTOP = "sway";
            };

            home.file.".config/sway-bak" = {
              source = "${unix}/dotfiles/linux/.config/sway";
              recursive = true;
            };

            home.file.".config/dwmbar/config.json".text = builtins.toJSON {
              clock = {
                interval = "1s";
                settings = { layout = "Monday, Jan 02 > 15:04"; };
              };
              volume = {
                interval = "200ms";
                settings = { backend = "pipewire"; };
              };
              fans = {
                interval = "1s";
                settings = { cache = true; limit = 2; };
              };
              temperatures = {
                interval = "5s";
                settings = { cache = true; separate = false; };
              };
              battery = {
                interval = "5s";
                settings = { cache = true; };
              };
              brightness = {
                interval = "500ms";
                settings = { cache = true; };
              };
              wifi = {
                interval = "30s";  # Heartbeat fallback interval (event-driven)
                settings = { backend = "iwd"; };
              };
            };

            programs.swaylock = swaylockCfg;
            programs.wofi = wofiCfg;

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

                keybindings = keys.keybindings;
                modes = keys.modes;

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
