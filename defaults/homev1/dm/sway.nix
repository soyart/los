username:

{ ... }:

{
  imports = [
    (import ../../../modules/homev1/dm/sway username)
  ];

  los.home."${username}".dm.sway.enable = true;
}
