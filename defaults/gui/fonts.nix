username:

{ pkgs, ... }:

{
  imports = [
    (import ../../home/gui/fonts.nix username)
  ];

  los.home."${username}".gui.fonts = {
    enable = true;

    packages = with pkgs; [
      hack-font
      inconsolata
      liberation_ttf
      tlwg # Thai font

      nerd-fonts.hack
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
