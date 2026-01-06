username:

{ ... }:

{
  imports = [
    (import ../../defaults/home/languages.nix username)
    (import ../../defaults/home/helix.nix username)
    (import ../../defaults/home/git.nix username)
    (import ../../defaults/home/bash.nix username)
    (import ../../defaults/home/lf.nix username)
    (import ../../defaults/home/firefox.nix username)
    (import ../../defaults/home/dm/sway.nix username)
    (import ../../defaults/home/dm/fonts.nix username)
    (import ../../defaults/home/dm/alacritty.nix username)
  ];
}
