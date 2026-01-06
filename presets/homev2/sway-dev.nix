# Sway developer preset for homev2
# A complete development environment with Sway, Firefox, VSCodium, and dev tools
#
# Usage:
#   los.homev2.artnoi = import ./presets/homev2/sway-dev.nix {
#     inherit lib pkgs;
#     withRust = true;
#     withGo = true;
#   };

{ lib
, pkgs
, withRust ? true
, withGo ? true
, withLfs ? false
}:

lib.foldl lib.recursiveUpdate {} [
  (import ../../defaults/homev2/bash.nix)
  (import ../../defaults/homev2/alacritty.nix)
  (import ../../defaults/homev2/sway.nix)
  (import ../../defaults/homev2/fonts.nix { inherit pkgs; })
  (import ../../defaults/homev2/firefox.nix)
  (import ../../defaults/homev2/helix.nix)
  (import ../../defaults/homev2/vscodium.nix)
  (import ../../defaults/homev2/lf.nix)
  (import ../../defaults/homev2/git.nix)
  (import ../../defaults/homev2/languages.nix)

  # Overrides for parameters
  {
    git.withLfs = withLfs;
    languages.go.enable = withGo;
    languages.rust.enable = withRust;
  }
]
