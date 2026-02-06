# Composable preset for development languages
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2 = {
#     username_1 = lib.mkMerge [
#       (import ../../presets/homev2/devel.nix { inherit lib; withGo = true; withRust = true; })
#     ];
#   };

{ lib
, withGo ? true
, withRust ? true
}:

lib.recursiveUpdate
  (import ../../defaults/homev2/languages.nix)
{
  languages.go.enable = withGo;
  languages.rust.enable = withRust;
}
