username:

{ lib, config, pkgs, ... }:

let
  types = lib.types;
  cfg = config.los.home."${username}".langs;

  mappings = {
    go = with pkgs; [
      go
      gopls
    ];

    rust = with pkgs; [
      cargo
      rustfmt
      rust-analyzer
    ];
  };

  mod = {
    options = {
      enable = lib.mkEnableOption "Enable language support (home-manager)";
      systemPackage = lib.mkEnableOption "Enable language support as system package";
    };
  };

  # Create a list of mod, with a new key "name".
  # e.g. If we have this config:
  #
  # { go = { enable=true; systemPackage=true;}; rust = { enable=true; systemPackage=true; }; }
  #
  # Then langList will be a list with 2 elements:
  #
  # [ {name=go; enable=true; systemPackage=true}; {name=rust; enable=true; systemPackage=true;} ]
  #
  langList = (langCfgs:
    lib.mapAttrsToList
      (key: val: val // { name = key; })
      langCfgs
  );

  sysPkgs = (langList:
    map
      (lang: lib.optionals (lang.enable && lang.systemPackage)
        mappings."${lang.name}"
      )
      langList
  );

  homePkgs = (langList:
    map
      (lang: lib.optionals (lang.enable && !lang.systemPackage)
        mappings."${lang.name}"
      )
      langList
  );

in
{
  options.los.home."${username}".langs = lib.mkOption {
    description = "Programming languages to install";
    type = types.attrsOf (types.submodule mod);
    default = {
      enable = false;
      systemPackage = false;
    };
  };

  config =
    let
      languages = langList cfg;

    in
    {
      environment.systemPackages =
        lib.lists.flatten (sysPkgs languages);

      home-manager.users."${username}".home.packages =
        lib.lists.flatten (homePkgs languages);
    };
}
