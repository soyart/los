# Minimal preset for homev2
# Just the basics: bash, git, helix, lf
#
# Usage:
#   los.homev2.bob = import ./presets/homev2/minimal.nix {};

{ withLfs ? false }:

{
  bash.enable = true;
  git = {
    enable = true;
    inherit withLfs;
  };
  helix.enable = true;
  lf.enable = true;
}

