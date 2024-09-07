# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ inputs, lib, config, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.impermanence.nixosModules.impermanence
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" =
      {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=6G" "mode=755" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/7CB3-65EB";
        fsType = "vfat";
      };

    "/nix" =
      {
        device = "/dev/disk/by-uuid/f5913f2e-1b06-4413-b03f-4201a6e194c3";
        fsType = "btrfs";
        options = [ "subvol=@nix" "compress=zstd:6" ];
      };

    "/home" =
      {
        device = "/dev/disk/by-uuid/f5913f2e-1b06-4413-b03f-4201a6e194c3";
        fsType = "btrfs";
        options = [ "subvol=@home" "compress=zstd:6" ];
      };

    "/persist" =
      {
        device = "/dev/disk/by-uuid/f5913f2e-1b06-4413-b03f-4201a6e194c3";
        fsType = "btrfs";
        neededForBoot = true;
        options = [ "subvol=@persist" "compress=zstd:6" ];
      };
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

  swapDevices =
    [{ device = "/dev/disk/by-uuid/86114262-1471-4b76-8149-f0966a1668c3"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
