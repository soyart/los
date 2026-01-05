username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/user/dm username)
  ];

  los.home."${username}".dm.fonts = {
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
