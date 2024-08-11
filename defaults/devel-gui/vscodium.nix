username:

{ ... }:

{
  imports = [
    (import ../../los/home/gui/progs/vscodium username)
  ];

  los.home."${username}".progs.vscodium = {
    enable = true;
  };
}
