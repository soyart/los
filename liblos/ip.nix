{ lib, pkgs, ... }:

with lib.lists;

let
  regexV4 = "(([0-9]+).([0-9]+).([0-9]+).([0-9]+))";
  regexV4WithPort = regexV4 + "\:([0-9]+)";

in
rec {
  inherit regexV4 regexV4WithPort;

  parseV4 = addr:
    let
      matched = builtins.match regexV4 addr;
      address = builtins.head matched;
      componentsInts = map strings.toInt (builtins.tail matched);

    in
    {
      inherit address;

      valid = matched != null
        && address != null
        && componentsInts != null
        && address == addr
        && builtins.length componentsInts == 4
        && builtins.all (x: x < 255) componentsInts;
    };

  isV4 = addr: (parseV4 addr).valid;

  parseV4WithPort = addr:
    let
      matched = builtins.match regexV4WithPort addr;
      address = builtins.head matched;
      componentsInts = map strings.toInt (builtins.tail matched);
      port = lists.last componentsInts;

    in
    {
      inherit address port;

      valid = matched != null
        && componentsInts != null
        && port != null
        && (port <= 65535)
        && (isV4 address);
    };

  isV4WithPort = addr: (parseV4WithPort addr).valid;
}
