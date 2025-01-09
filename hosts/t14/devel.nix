username:

{ pkgs, ... }:

{
  los.home."${username}".progs.helix = {
    langServers = with pkgs; [
      # By default, bash-lsp should use shellcheck and shfmt
      bash-language-server
      shellcheck
      shfmt

      clang-tools
    ];
  };
}
