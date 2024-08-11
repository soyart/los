username:

{ pkgs, ... }:

{
  imports = [
    (import ../../los/home/progs/git username)
  ];

  los.home."${username}".progs.git = {
    enable = true;
    withLfs = false;
    username = "soyart";
    email = "artdrawin@gmail.com";

    editor = {
      package = pkgs.helix;
      binPath = "bin/hx";
    };
  };
}
