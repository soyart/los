username:

{ ... }:

{
  imports = [
    (import ../../modules/home/languages username)
  ];

  los.home."${username}".languages = {
    go.enable = true;
    rust.enable = true;
  };
}
