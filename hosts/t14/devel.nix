username:

{ pkgs, ... }:

{
  los.home."${username}".progs.helix = {
    langServers = with pkgs; [
      shellcheck
      clang-tools
    ];
  };
}
