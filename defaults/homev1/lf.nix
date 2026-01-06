username:

{ ... }:

{
  imports = [
    (import ../../modules/homev1/lf username)
  ];

  los.home."${username}".lf.enable = true;
}
