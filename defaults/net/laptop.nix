{ ... }:

{
  imports = [
    ../../modules/system/net
    ./.
  ];

  los.net = {
    iwd.enable = true;
  };
}
