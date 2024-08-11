username:

{ lib, config, pkgs, inputs, ... }:

let
  cfg = config.los.home."${username}".gui.progs.sway;
  unix = inputs.unix;

in
{
  options = {
    los.home."${username}".gui.progs.sway = {
      enable = lib.mkEnableOption "Enable Sway DM with config from gitlab.com/artnoi/unix";
    };
  };

  config = lib.mkIf cfg.enable {
    security = {
      polkit.enable = true;
      rtkit.enable = true;
      pam.services.swaylock = { };
    };

    services.pipewire = {
      enable = true;

      pulse.enable = true; # Emulate PulseAudio
      alsa.enable = true;
    };

    users.users."${username}" = {
      extraGroups = [ "audio" "video" ];
    };

    hardware = {
      graphics.enable = true;
    };

    home-manager.users."${username}" = {
      home.packages = [
        pkgs.swayidle
        pkgs.swaylock
        pkgs.alacritty # Default terminal in sway config from unix
        pkgs.wl-clipboard
        pkgs.brightnessctl
        pkgs.dash
        pkgs.lm_sensors
        pkgs.wofi
        pkgs.dmenu
      ] ++ [
        (pkgs.writeShellScriptBin "sndctl" ''
          ${builtins.readFile "${unix}/sh-tools/bin/sndctl-wireplumber"}
        '')
      ];

      home.sessionVariables = {
        WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };

      home.file = {
        ".config/sway" = {
          source = "${unix}/dotfiles/linux/.config/sway";
          recursive = true;
        };

        ".config/dwm" = {
          source = "${unix}/dotfiles/linux/.config/dwm";
          recursive = true;
        };

        ".config/wofi" = {
          source = "${unix}/dotfiles/linux/.config/wofi";
          recursive = true;
        };

        "bin" = {
          source = "${unix}/sh-tools/bin";
          recursive = true;
        };

        # @TODO: separate module
        ".config/alacritty" = {
          source = "${unix}/dotfiles/pkg/alacritty/.config/alacritty";
          recursive = true;
        };

        "wall" = {
          source = ../../wall;
          recursive = true;
        };
      };

      wayland.windowManager.sway = {
        enable = true;
        extraConfig = ''
          include ${unix}/dotfiles/linux/.config/sway/config
        '';
      };
    };
  };
}
