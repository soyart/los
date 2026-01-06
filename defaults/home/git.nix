username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/home/git username)
  ];

  los.home."${username}".git = {
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
