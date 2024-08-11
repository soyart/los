username:

{ ... }:

{
  imports = [
    (import ./git.nix username)
    (import ./langs.nix username)
    (import ./helix.nix username)
  ];
}
