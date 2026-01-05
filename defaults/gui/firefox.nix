username:

{ ... }:

{
  imports = [
    (import ../../modules/user/firefox username)
  ];

  los.home."${username}".firefox.enable = true;
  # pipewireOverride = null means auto-detect from config.services.pipewire.enable
}
