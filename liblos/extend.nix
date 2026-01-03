{ lib, pkgs, ... }:

({ base
 , check
 }: lib.types.addCheck base check)
