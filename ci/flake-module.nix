# GitLab CI (nix-gitlab-ci). Imported from the root flake via flake-parts.
{ inputs, ... }:
{
  imports = [
    ../.gitlab/ci.nix
  ];
}
