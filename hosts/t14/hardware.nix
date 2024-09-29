{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
  };
}
