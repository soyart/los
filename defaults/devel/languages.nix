username:

{ ... }:

{
  imports = [
    ../../modules/user/devel  # No closure needed - module uses types.attrsOf
  ];

  los.home."${username}".devel = {
    go.enable = true;
    rust.enable = true;
  };
}
