username:

{ ... }:

{
  imports = [
    (import ../../modules/homev1/vscodium username)
  ];

  los.home."${username}".vscodium = {
    enable = true;
  };
}
