username:

{ ... }:

{
  imports = [
    (import ../../../modules/home/dm/sway username)
  ];

  los.home."${username}".dm.sway.enable = true;
}
