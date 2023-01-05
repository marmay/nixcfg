{ config, lib, pkgs, ... }:
{
  config = {
    boot = {
      initrd = {
        availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sr_mod"
        ];
        kernelModules = [
        ];
      };

      kernelModules = [
        "kvm-amd"
        "sg"
      ];
      blacklistedKernelModules = [
        "r8169"
      ];
      extraModulePackages = with config.boot.kernelPackages; [
        r8168
      ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/aa277e21-208d-4fcf-a197-f0d4f923c6a4";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/67BB-28F7";
        fsType = "vfat";
      };

      "/media/backup" = {
        device = "/dev/disk/by-uuid/49812bde-7047-4802-8e70-c029dbf37c05";
        fsType = "btrfs";
      };
    };

    swapDevices = [
      {
        device = "/dev/disk/by-uuid/6bba504a-3859-42ab-9837-a6f223a45018";
      }
    ];
  };
}

