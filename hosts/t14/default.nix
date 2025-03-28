{ pkgs, hostname, mainUsername, ... }:

{
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ./configuration.nix

    # Programming/editor setup
    (import ./devel.nix mainUsername)

    ../../defaults/nix
    ../../defaults/net

    ../../nixos/net
    ../../nixos/syspkgs.nix
    ../../nixos/main-user.nix
    ../../nixos/doas.nix # doas is considered a system setting
    ../../nixos/ramdisk.nix
  ];

  networking.hostName = hostname;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    blacklistedKernelModules = [
      "btusb"
      "bluetooth"
      "uvcvideo"
    ];

    # Use the systemd-boot EFI boot loader.
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices = {
      crypted = {
        device = "/dev/disk/by-uuid/31e319df-c4fe-48f5-82f5-49c7a5503119";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  los = {
    ramDisks = {
      "/tmp" = {
        group = "wheel";
      };
      "/rd" = {
        size = "2G";
        group = mainUsername;
        owner = mainUsername;
      };
    };

    mainUser = {
      enable = true;
      username = mainUsername;
      hashedPassword = "$y$j9T$QZuckOzqsP51oy3Zcy80a0$pKmSSkRU4.0DIbhsGv1ZwQ277iqdkBOHRSQ8WkCMcG1";
    };

    doas = {
      enable = true;
      keepSudo = false;
      settings = {
        users = [ mainUsername ];
        keepEnv = true;
        persist = true;
      };
    };

    net = {
      iwd.enable = true;
    };

    syspkgs = [
      ../../packages/base
      ../../packages/devel
      ../../packages/net
      ../../packages/laptop
      ../../packages/nix-extras
    ];
  };

  environment.systemPackages = [
    # Other packages go here
  ];

  programs.nano.enable = false;

  services = {
    journald.extraConfig = "SystemMaxUse=100M";

    fwupd.enable = true;
    locate.enable = true;

    # automatic-timezoned requires avahi as well
    # See issues:
    # automatic-timezoned and geoclue2 https://github.com/NixOS/nixpkgs/issues/329522
    # geoclue2 failures due to Mozilla Location Service going defunct https://github.com/NixOS/nixpkgs/issues/321121
    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  home-manager.users."${mainUsername}" = {
    home.stateVersion = "24.05";
  };
}
