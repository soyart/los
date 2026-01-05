username:

{ ... }:

{
  imports = [
    (import ../../modules/user/dm/sway username)
  ];

  los.home."${username}".dm.sway.enable = true;
}
