{ pkgs, hostname, ... }:

let
  username = "artnoi";
in
{
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ./configuration.nix

    # Programming/editor setup
    (import ./devel.nix username)

    ../../defaults/nix
    ../../defaults/net

    ../../nixos/net
    ../../nixos/syspkgs.nix
    ../../nixos/users.nix
    ../../nixos/doas.nix # doas is considered a system setting
    ../../nixos/ramdisk.nix

    # User-specific presets (moved from hosts/default.nix)
    (import ../../presets/sway-dev username)
    (import ../../defaults/devel-gui/vscodium.nix username)
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
        group = "los-users";
        owner = username;
      };
    };

    users = [
      {
        inherit username;
        superuser = true;
        hashedPassword = "$y$j9T$QZuckOzqsP51oy3Zcy80a0$pKmSSkRU4.0DIbhsGv1ZwQ277iqdkBOHRSQ8WkCMcG1";
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
    automatic-timezoned.enable = true;
  };
}
