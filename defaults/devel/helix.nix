username:

{ pkgs, ... }:

{
  imports = [
    (import ../../modules/user/helix username)
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
