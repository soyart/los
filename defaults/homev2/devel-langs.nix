# Simple attrset default for devel languages
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2.artnoi = import ../../defaults/homev2/devel-langs.nix;

{
  devel.go.enable = true;
  devel.rust.enable = true;
}

