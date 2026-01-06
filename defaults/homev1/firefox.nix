username:

{ ... }:

{
  imports = [
    (import ../../modules/homev1/firefox username)
  ];

  los.home."${username}".firefox.enable = true;
  # pipewireOverride = null means auto-detect from config.services.pipewire.enable
}
