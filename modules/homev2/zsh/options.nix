{ lib, ... }:

{
  options.zsh = {
    enable = lib.mkEnableOption "Enable ZSh shell with los defaults";
  };
}

