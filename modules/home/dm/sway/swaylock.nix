username:

{ inputs, ... }:

let
  colors = import ./colors.nix;

in
{
  home-manager.users."${username}".programs.swaylock = {
    enable = true;
    settings = {
      image = "${inputs.self}/assets/wall/scene2.jpg";
      color = colors.dark1;
    };
  };
}

