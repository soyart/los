{ inputs, lib, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems."/" = lib.mkOverride 0 {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=6G" "mode=755" ];
  };

  fileSystems."/persist" = lib.mkOverride 0 {
    device = "/dev/disk/by-uuid/f5913f2e-1b06-4413-b03f-4201a6e194c3";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=@persist" "compress=zstd:6" ];
  };

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/iwd"
      "/etc/iwd"
      # { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
