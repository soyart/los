username:

{ ... }:

{
  imports = [
    (import ../../modules/home/devel username)
  ];

  los.home."${username}".devel = {
    go.enable = true;
    rust.enable = true;
  };
}
