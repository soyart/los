# Default fonts config for homev2
# Usage: los.homev2.artnoi = import ./defaults/homev2/fonts.nix { inherit pkgs; };
{ pkgs }:

{
  fonts = {
    enable = true;
    packages = with pkgs; [
      hack-font
      inconsolata
      liberation_ttf
      tlwg
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

