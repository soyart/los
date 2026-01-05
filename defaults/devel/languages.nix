username:

{ ... }:

{
  imports = [
    (import ../../modules/user/devel username)
  ];

  los.home."${username}".devel = {
    go.enable = true;
    rust.enable = true;
  };
}
