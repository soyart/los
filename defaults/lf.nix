username:

{ ... }:

{
  imports = [
    (import ../home/progs/lf username)
  ];

  los.home."${username}".progs.lf.enable = true;
}
