# Sway config module
#
# Note: Sway has system-level effects (pipewire, security, hardware, users.groups)
# that must be handled carefully in homev2 context.

{ lib, config, pkgs, inputs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };

  # Import split config files
  keys = import ./keybindings.nix { inherit mod dmenutrackpad; };
  swaylockCfg = import ./swaylock.nix { inherit colors wallpaper; };
  wofiCfg = import ./wofi.nix;
  wallpaper = "${inputs.self}/assets/wall/scene2.jpg";
  colors = import ./colors.nix;
  scripts = import ./scripts.nix { inherit pkgs; };

  # Flake self packages
  losPkgs = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}";
  dwmbar = losPkgs.dwmbar;
  dmenutrackpad = losPkgs.dmenutrackpad;

  # Legacy dotfiles
  unix = inputs.unix;

  mod = "Mod1";
in
{
  config = lib.mkMerge [
    # Global system-wide config (only if ANY user has sway enabled)
    (lib.mkIf (homev2.anyEnabled config "sway") {
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

    # Per-user configs
    {
      # Allow wofipower to be called without passwords by doas
      los.doas.noPasswords = lib.mkIf config.los.doas.enable (homev2.mapEnabledUsers config "sway" (username: _: {
        inherit username;
        cmd = "${scripts.wofipower}";
      }));

      # Allow wofipower to be called without passwords by sudo
      security.sudo.extraRules = lib.mkIf (!config.los.doas.enable)
        (homev2.mapEnabledUsers config "sway" (username: _: {
          users = [ username ];
          commands = [
            {
              command = scripts.wofipower;
              options = "NOPASSWD";
            }
          ];
        }));

      users.users = homev2.mkConfigPerUser config (username: userCfg:
        lib.mkIf userCfg.sway.enable {
          extraGroups = [ "audio" "video" ];
        }
      );

      home-manager.users = homev2.mkConfigPerUser config (username: userCfg:
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
              settings = { cache = true; merge = true; };
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
              interval = "30s"; # Heartbeat fallback interval (event-driven)
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
                statusCommand = "${dwmbar}/bin/dwmbar";
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
      );
    }
  ];
}
