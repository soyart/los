# Sway developer preset for homev2
# A complete development environment with Sway, Firefox, VSCodium, and dev tools
#
# Usage:
#   los.homev2.artnoi = import ./presets/homev2/sway-dev.nix {
#     inherit pkgs;
#     withRust = true;
#     withGo = true;
#   };

{ pkgs
, withRust ? true
, withGo ? true
, withLfs ? false
}:

{
  # Display manager
  sway.enable = true;

  # Fonts
  fonts = {
    enable = true;
    packages = with pkgs; [
      hack-font
      inconsolata
      liberation_ttf
    ];
  };

  # Browser
  firefox.enable = true;

  # Editor and IDE
  helix.enable = true;
  vscodium.enable = true;

  # File manager
  lf.enable = true;

  # Git
  git = {
    enable = true;
    inherit withLfs;
  };

  # Development languages
  devel = {
    go.enable = withGo;
    rust.enable = withRust;
  };
}

