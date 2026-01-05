username:

{ lib, config, pkgs, inputs, ... }:

let
  cfg = config.los.home."${username}".dm.sway;
  unix = inputs.unix;
  scripts = import ./scripts.nix { inherit pkgs; };


in
{
  imports = [
    (import ./config.nix username)
    (import ./keybindings.nix username)
    (import ./swaylock.nix username)
    (import ./wofi.nix username)
  ];

  options = {
    los.home."${username}".dm.sway = {
      enable = lib.mkEnableOption "Enable los Sway DM";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable pipewire directly (read by firefox via config.services.pipewire.enable)
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

    los.doas.noPasswords = [
      {
        inherit username;
        cmd = "${scripts.wofipower}";
      }
    ];

    users.users."${username}" = {
      extraGroups = [ "audio" "video" ];
    };

    hardware = {
      graphics.enable = true;
    };

    home-manager.users."${username}" = {
      home.packages = [
        pkgs.swayidle
        pkgs.alacritty
        pkgs.wl-clipboard
        pkgs.brightnessctl
        pkgs.dash
        pkgs.lm_sensors
      ] ++ [
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

      home.file = {
        ".config/sway-bak" = {
          source = "${unix}/dotfiles/linux/.config/sway";
          recursive = true;
        };
      };
    };
  };
}

