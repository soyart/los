{ inputs }:

let wallpaper = "${inputs.self}/assets/wall/scene2.jpg";

in
{
  sway = {
    inherit wallpaper;
    enable = true;
    wallpaperLock = wallpaper;
  };
}

