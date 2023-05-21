{ config, lib, pkgs, stdenv, ... }:
{
  options.marmar.rpi = lib.mkEnableOption "Raspberry Pi support";

  config = lib.mkIf config.marmar.rpi {
    # Makes `availableOn` fail for zfs, see <nixos/modules/profiles/base.nix>.
    # This is a workaround since we cannot remove the `"zfs"` string from `supportedFilesystems`.
    # The proper fix would be to make `supportedFilesystems` an attrset with true/false which we
    # could then `lib.mkForce false`
    nixpkgs.overlays = [
      (final: super: {
        zfs = super.zfs.overrideAttrs(_: {
          meta.platforms = [];
        });
      })
      (final: super: {
        makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
      })
      (final: super: {
        linuxPackages_rpi4 = super.linuxPackages_rpi4.extend (lpself: lpsuper: {
          kernel = lpsuper.kernel.overrideDerivation (oldAttrs: {
            postFixup = oldAttrs.postFixup + ''
              copyDTB bcm2711-rpi-400.dtb bcm2838-rpi-400.dtb
            '';
          });
        });
      })
    ];

    # As we do not have passwords set up on the initial boot, we must be able to trigger
    # a system update. For that purpose, we log in as root without a password. Once the
    # system is up and running, we disable the root account.
    users.users.root.initialHashedPassword = "";

    hardware.deviceTree.filter = lib.mkForce "bcm2711-rpi-400.dtb";

    boot = {
      kernelPackages = pkgs.linuxPackages_rpi4;
      tmp.useTmpfs = true;
    };
  };
}
