username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/user/progs/helix username)
  ];

  los.home."${username}".progs.helix = {
    enable = true;
    langServers = with pkgs; [
      nixd
      nixpkgs-fmt

      go
      gopls
      gotools
      go-tools
    ];
  };
}
