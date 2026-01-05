username:

{ ... }:

{
  imports = [
    (import ../../modules/user/vscodium username)
  ];

  los.home."${username}".vscodium = {
    enable = true;
  };
}
