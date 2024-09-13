username:

{ ... }:

{
  imports = [
    (import ../../home/progs/helix username)
  ];

  los.home."${username}".progs.helix.enable = true;
}
