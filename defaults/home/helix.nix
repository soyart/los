username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/home/helix username)
  ];

  los.home."${username}".helix = {
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
