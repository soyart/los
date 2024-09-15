username:

{ lib, config, pkgs, inputs, ... }:

let
  cfg = config.los.home."${username}".gui.progs.sway;
  unix = inputs.unix;

in
{
  imports = [
    (import ./config.nix username)
    (import ./keybindings.nix username)
  ];

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
        "bin" = {
          source = "${unix}/sh-tools/bin";
          recursive = true;
        };

        "wall" = {
          source = ../../wall;
          recursive = true;
        };

        ".config/sway-bak" = {
          source = "${unix}/dotfiles/linux/.config/sway";
          recursive = true;
        };

        ".config/swaylock" = {
          source = "${unix}/dotfiles/linux/.config/swaylock";
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
      };

      # TODO: Move to config.nix
      wayland.windowManager.sway = {
        enable = true;
        # extraConfig = ''
        #   include ${unix}/dotfiles/linux/.config/sway/config
        # '';
      };
    };
  };
}
