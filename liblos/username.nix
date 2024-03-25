{ lib, purpose }:

lib.mkOption {
  description = "username to enable ${purpose} for";
  type = lib.types.str // {
    check = s: (builtins.stringLength s) != 0;
  };
}
