# Sway config module
#
# Note: Sway has system-level effects (pipewire, security, hardware, users.groups)
# that must be handled carefully in homev2 context.

{ lib, config, pkgs, inputs, ... }:

let
  homev2 = import ../lib.nix { inherit lib; };

  # Flake self packages
  losPkgs = inputs.self.packages."${pkgs.stdenv.hostPlatform.system}";

  # Import split config files
  wofiCfg = import ./wofi.nix;
  colors = import ./colors.nix;
  scripts = import ./scripts.nix { inherit pkgs; };
  keys = import ./keybindings.nix { inherit (losPkgs) dmenutrackpad; mod = modifier; };
  dwmbar = import ./dwmbar.nix { inherit colors; inherit (losPkgs) dwmbar; };

  # Legacy dotfiles
  unix = inputs.unix;

  modifier = "Mod1";
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
          commands = [
            {
              users = [ username ];
              command = scripts.wofipower;
              options = [ "NOPASSWD" ];
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

          programs.wofi = wofiCfg;
          programs.swaylock = import ./swaylock.nix {
            inherit colors;
            wallpaper = userCfg.sway.wallpaperLock;
          };

          wayland.windowManager.sway = {
            enable = true;
            config = {
              inherit modifier;
              inherit (keys) modes keybindings;

              startup = [
                {
                  command = ''
                    exec swayidle -w timeout 300 'swaylock -f -c 000000' timeout 360 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock'
                  '';
                  always = true;
                }
              ];

              output."*".bg = "${userCfg.sway.wallpaper} fill";
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

              bars = [
                dwmbar.bar
              ];
            };
          };

          home.file = {
            ".config/dwmbar/config.json".text = builtins.toJSON dwmbar.dwmbarConfig;
            ".config/sway-bak" = {
              # Backup sway config files from Arch
              source = "${unix}/dotfiles/linux/.config/sway";
              recursive = true;
            };
          };
        }
      );
    }
  ];
}
