# Minimal preset for homev2
# Just the basics: bash, git, helix, lf
#
# Usage:
#   los.homev2.bob = import ./presets/homev2/minimal.nix { inherit lib; };

{ lib
, withLfs ? false
}:

lib.foldl lib.recursiveUpdate { } [
  (import ../../defaults/homev2/bash.nix)
  (import ../../defaults/homev2/git.nix)
  (import ../../defaults/homev2/helix.nix)
  (import ../../defaults/homev2/lf.nix)

  # Override for parameter
  {
    git.withLfs = withLfs;
  }
]
