{ lib, inputs, ... }:

let
  wallpaperDefault = "${inputs.self}/assets/wall/scene2.jpg";

in
{
  options.sway = {
    enable = lib.mkEnableOption "Enable los Sway DM";
    wallpaper = lib.mkOption {
      description = "Path to sway background";
      type = lib.types.str;
      default = wallpaperDefault;
      example = "/path/to/some/wallpaper";
    };
    wallpaperLock = lib.mkOption {
      description = "Path to swaylock background";
      type = lib.types.str;
      default = wallpaperDefault;
      example = "/path/to/some/wallpaper";
    };
  };
}

