username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/user/git username)
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
