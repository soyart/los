# Sway developer preset for homev2
# A complete development environment with Sway, Firefox, VSCodium, and dev tools
#
# Usage:
#   los.homev2.username_1 = import ./presets/homev2/sway-dev.nix {
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

lib.foldl lib.recursiveUpdate { } [
  (import ../../modules/homev2/bash/defaults.nix)
  (import ../../modules/homev2/alacritty/defaults.nix)
  (import ../../modules/homev2/sway/defaults.nix)
  (import ../../modules/homev2/fonts/defaults.nix { inherit pkgs; })
  (import ../../modules/homev2/firefox/defaults.nix)
  (import ../../modules/homev2/helix/defaults.nix)
  (import ../../modules/homev2/vscodium/defaults.nix)
  (import ../../modules/homev2/lf/defaults.nix)
  (import ../../modules/homev2/git/defaults.nix)
  (import ../../modules/homev2/languages/defaults.nix)

  # Overrides for parameters
  {
    git.withLfs = withLfs;
    languages.go.enable = withGo;
    languages.rust.enable = withRust;
  }
]
