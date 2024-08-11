{ pkgs ? import <nixpkgs> { } }:

let
  envName = "dev-go";
  aliasesGit = builtins.readFile ../git-aliases.sh;

in
{
  devShell = pkgs.mkShellNoCC {
    HELLO = "world";
    ENV_NAME = envName;

    shellHook = ''
      echo "Entering nix-shell for ${envName}";
      ${aliasesGit}
    '';

    buildInputs = with pkgs; [
      go_1_21
      gotools
      gofumpt
      golangci-lint
      efm-langserver
    ];
  };
}
