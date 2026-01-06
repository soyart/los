username:

{ ... }:

{
  imports = [
    (import ../modules/home/lf username)
  ];

  los.home."${username}".lf.enable = true;
}
