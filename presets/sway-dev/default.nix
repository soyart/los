username:

{ ... }:

{
  imports = [
    (import ../../defaults/homev1/languages.nix username)
    (import ../../defaults/homev1/helix.nix username)
    (import ../../defaults/homev1/git.nix username)
    (import ../../defaults/homev1/bash.nix username)
    (import ../../defaults/homev1/lf.nix username)
    (import ../../defaults/homev1/firefox.nix username)
    (import ../../defaults/homev1/dm/sway.nix username)
    (import ../../defaults/homev1/dm/fonts.nix username)
    (import ../../defaults/homev1/dm/alacritty.nix username)
  ];
}
