username:

{ ... }:

{
  imports = [
    (import ../../modules/home/firefox username)
  ];

  los.home."${username}".firefox.enable = true;
  # pipewireOverride = null means auto-detect from config.services.pipewire.enable
}
