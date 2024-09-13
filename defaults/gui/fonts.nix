username:

{ pkgs, ... }:

{
  imports = [
    (import ../../home/gui/fonts.nix username)
  ];

  los.home."${username}".gui.fonts = {
    enable = true;

    ttf = with pkgs; [
      hack-font
      inconsolata
      liberation_ttf

      tlwg # Thai font
    ];

    nerd = [
      "Hack"
    ];

    defaults = {
      sansSerif = [
        "Liberation"
      ];

      monospace = [
        "Hack"
      ];
    };
  };
}
