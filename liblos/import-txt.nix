{ pkgs }:


with pkgs;
target: lib.pipe target [
  builtins.readFile
  (lib.splitString "\n")
  (lib.filter (x: x != ""))
  (lib.filter (x: !(lib.strings.hasPrefix "#" x)))
  (lib.flip lib.attrVals pkgs)
]
