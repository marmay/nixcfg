{ config, lib, pkgs, ... }:
{
  options.marmar.rpi = lib.mkEnableOption "Raspberry Pi support";
  options.marmar.vc4-kms = lib.mkEnableOption "Enable vc4-kms";

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
    ];

    # As we do not have passwords set up on the initial boot, we must be able to trigger
    # a system update. For that purpose, we log in as root without a password. Once the
    # system is up and running, we disable the root account.
    users.users.root.initialHashedPassword = "";

    boot = {
      kernelPackages = pkgs.linuxPackages_rpi4;
      tmp.useTmpfs = true;
    };

  } // lib.mkIf config.marmar.vc4-kms {
    hardware.deviceTree.overlays = [
      {
        name = "rpi4-cma-overlay";
        dtsText = ''
          // SPDX-License-Identifier: GPL-2.0
          /dts-v1/;
          /plugin/;

          / {
            compatible = "brcm,bcm2711";
            fragment@0 {
              target = <&cma>;
              __overlay__ {
                size = <(512 * 1024 * 1024)>;
              };
            };
          };
        '';
      }
      {
        name = "rpi4-vc4-kms-v3d-overlay";
        dtsText = ''
          /*
           * vc4-kms-v3d-overlay.dts
           */

          /dts-v1/;
          /plugin/;

          / {
          	compatible = "brcm,bcm2711";

          	fragment@1 {
          		target = <&i2c2>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@2 {
          		target = <&fb>;
          		__overlay__  {
          			status = "disabled";
          		};
          	};

          	fragment@3 {
          		target = <&pixelvalve0>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@4 {
          		target = <&pixelvalve1>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@5 {
          		target = <&pixelvalve2>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@6 {
          		target = <&hvs>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@7 {
          		target = <&hdmi>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@8 {
          		target = <&v3d>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@9 {
          		target = <&vc4>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@10 {
          		target = <&clocks>;
          		__overlay__  {
          			claim-clocks = <
          				34
          				35
          				15
          				16
          			>;
          		};
          	};

          	fragment@11 {
          		target = <&vec>;
          		__dormant__  {
          			status = "okay";
          		};
          	};

          	fragment@12 {
          		target = <&txp>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@13 {
          		target = <&hdmi>;
          		__dormant__  {
          			dmas;
          		};
          	};

          	fragment@14 {
          		target = <&chosen>;
          		__overlay__  {
          			bootargs = "snd_bcm2835.enable_hdmi=0";
          		};
          	};

          	__overrides__ {
          		audio   = <0>,"!13";
          		noaudio = <0>,"=13";
          		composite = <0>, "=11";
          		nohdmi = <0>, "-1-7";
          	};
          };
        '';
      }
    ];
  };
}
