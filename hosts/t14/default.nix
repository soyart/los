{ lib, pkgs, hostname, ... }:

let
  artnoi = "artnoi";

in
{
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ./configuration.nix

    ../../modules/system/syspkgs.nix
    ../../modules/system/users.nix
    ../../modules/system/doas.nix # doas is considered a system setting
    ../../modules/system/ramdisk.nix

    ../../defaults/system/nix
    ../../defaults/system/net/laptop.nix

    # homev2 module system (attrsOf-based per-user config)
    ../../modules/homev2
  ];

  # Per-user configuration using homev2
  los.homev2.${artnoi} = import ../../presets/homev2/sway-dev.nix {
    inherit lib pkgs;
    withRust = true;
    withGo = true;
  };

  networking.hostName = hostname;
  users.mutableUsers = false;

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
    users = [
      {
        username = artnoi;
        superuser = true;
        hashedPassword = "$y$j9T$QZuckOzqsP51oy3Zcy80a0$pKmSSkRU4.0DIbhsGv1ZwQ277iqdkBOHRSQ8WkCMcG1";
        homeStateVersion = "24.05";
      }
      {
        username = "los-t14-normal-user";
        superuser = false;
        hashedPassword = "$6$3/KBWh.tWFriD8Pr$WCQHYNEbz2BnOF0ZLmXclgEGHSiSTi0S87nImMk2dH.lKGk.wfgJkjPsKbu7vLXsiZRugfwW5EBHSDTfy04rt1";
        homeStateVersion = "24.05";
      }
    ];

    doas = {
      # enable and settings.users are set by users.nix for superusers
      keepSudo = false;
      settings = {
        keepEnv = true;
        persist = true;
      };
    };

    ramDisks = {
      "/tmp" = {
        group = "wheel";
      };
      "/rd" = {
        size = "2G";
        group = artnoi;
        owner = artnoi;
      };
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
    avahi.enable = true;
  };
}
