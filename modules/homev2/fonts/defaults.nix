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

