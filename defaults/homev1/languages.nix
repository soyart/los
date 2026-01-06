username:

{ ... }:

{
  imports = [
    (import ../../modules/homev1/languages username)
  ];

  los.home."${username}".languages = {
    go.enable = true;
    rust.enable = true;
  };
}
