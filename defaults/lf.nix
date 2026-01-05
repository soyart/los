username:

{ ... }:

{
  imports = [
    (import ../modules/user/lf username)
  ];

  los.home."${username}".lf.enable = true;
}
