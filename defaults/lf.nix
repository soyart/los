username:

{ ... }:

{
  imports = [
    (import ../modules/user/progs/lf username)
  ];

  los.home."${username}".progs.lf.enable = true;
}
