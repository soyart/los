{ lib, purpose }:

lib.mkOption {
  description = "username to enable ${purpose} for";
  type = lib.types.addCheck lib.types.str (
    name: (builtins.stringLength name) != 0
  );
}
