{ config, lib, inputs, ... }:
{
  options.marmar.rpi = lib.mkEnableOption "Raspberry Pi support";

  config = lib.mkIf config.marmar.rpi {
    # Makes `availableOn` fail for zfs, see <nixos/modules/profiles/base.nix>.
    # This is a workaround since we cannot remove the `"zfs"` string from `supportedFilesystems`.
    # The proper fix would be to make `supportedFilesystems` an attrset with true/false which we
    # could then `lib.mkForce false`
    nixpkgs.overlays = [(final: super: {
      zfs = super.zfs.overrideAttrs(_: {
        meta.platforms = [];
      });
    })];

    # As we do not have passwords set up on the initial boot, we must be able to trigger
    # a system update. For that purpose, we log in as root without a password. Once the
    # system is up and running, we disable the root account.
    users.users.root.initialHashedPassword = "";

    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };

      kernelParams = [
        "8250.nr_uarts=1"
        "console=tty1"
        "cma=256M"
      ];

      initrd.availableKernelModules = [
        "usbhid"
        "usb_storage"
        "vc4"
        "bcm2835_dma"
        "i2c_bcm2835"
      ];

      tmp.useTmpfs = true;
    };
  };
}
