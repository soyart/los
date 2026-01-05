# Composable preset for development environment
#
# Usage in host config:
#   imports = [ ../../modules/homev2 ];
#   los.homev2 = {
#     artnoi = lib.mkMerge [
#       (import ../../presets/homev2/devel.nix { withGo = true; withRust = true; })
#     ];
#   };

{ withGo ? true
, withRust ? true
}:

{
  languages.go.enable = withGo;
  languages.rust.enable = withRust;
}

