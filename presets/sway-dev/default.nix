username:

{ ... }:

{
  imports = [
    (import ../../defaults/bash.nix username)
    (import ../../defaults/devel username)

    (import ../../defaults/gui/sway.nix username)
    (import ../../defaults/gui/fonts.nix username)
    (import ../../defaults/gui/firefox.nix username)
    (import ../../defaults/gui/alacritty.nix username)
  ];
}
