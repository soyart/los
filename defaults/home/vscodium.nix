username:

{ ... }:

{
  imports = [
    (import ../../modules/home/vscodium username)
  ];

  los.home."${username}".vscodium = {
    enable = true;
  };
}
