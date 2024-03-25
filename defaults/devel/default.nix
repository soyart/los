username:

{ ... }:

{
  imports = [
    (import ./git.nix username)
    (import ./helix.nix username)
    (import ./languages.nix username)
  ];
}
