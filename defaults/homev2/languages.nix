# Simple attrset default for devel languages
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2.artnoi = import ../../defaults/homev2/devel-langs.nix;

{
  languages.go.enable = true;
  languages.rust.enable = true;
}

