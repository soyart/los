# Minimal preset for homev2
# Just the basics: bash, git, helix, lf
#
# Usage:
#   los.homev2.bob = import ./presets/homev2/minimal.nix { inherit lib; };

{ lib
, withLfs ? false
}:

lib.foldl lib.recursiveUpdate { } [
  (import ../../modules/homev2/bash/defaults.nix)
  (import ../../modules/homev2/git/defaults.nix)
  (import ../../modules/homev2/helix/defaults.nix)
  (import ../../modules/homev2/lf/defaults.nix)

  # Override for parameter
  {
    git.withLfs = withLfs;
  }
]
