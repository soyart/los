# Firefox submodule options for los.homev2.<user>

{ lib, ... }:

{
  options.firefox = {
    enable = lib.mkEnableOption "Enable Firefox (Wayland-only)";
    pipewireOverride = lib.mkOption {
      description = "Override Pipewire support in Firefox. null = auto-detect from system config";
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
  };
}

