username:

{ ... }:

{
  imports = [
    (import ../../modules/user/gui/progs/vscodium username)
  ];

  los.home."${username}".progs.vscodium = {
    enable = true;
  };
}
