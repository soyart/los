username:

{ ... }:

{
  imports = [
    (import ../../modules/user/gui/progs/sway username)
  ];

  los.home."${username}".gui.progs.sway.enable = true;
}
