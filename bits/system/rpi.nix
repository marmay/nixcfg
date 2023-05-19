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
           * vc4-kms-v3d-pi4-overlay.dts
           */

          /dts-v1/;
          /plugin/;

          &frag0 {
          	size = <((512-4)*1024*1024)>;
          };

          / {
          	compatible = "brcm,bcm2711";

          	fragment@1 {
          		target = <&ddc0>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@2 {
          		target = <&ddc1>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@3 {
          		target = <&hdmi0>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@4 {
          		target = <&hdmi1>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@5 {
          		target = <&hvs>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@6 {
          		target = <&pixelvalve0>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@7 {
          		target = <&pixelvalve1>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@8 {
          		target = <&pixelvalve2>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@9 {
          		target = <&pixelvalve3>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@10 {
          		target = <&pixelvalve4>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@11 {
          		target = <&v3d>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@12 {
          		target = <&vc4>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@13 {
          		target = <&txp>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@14 {
          		target = <&fb>;
          		__overlay__  {
          			status = "disabled";
          		};
          	};

          	fragment@15 {
          		target = <&firmwarekms>;
          		__overlay__  {
          			status = "disabled";
          		};
          	};

          	fragment@16 {
          		target = <&vec>;
          		__overlay__  {
          			status = "disabled";
          		};
          	};

          	fragment@17 {
          		target = <&hdmi0>;
          		__dormant__  {
          			dmas;
          		};
          	};

          	fragment@18 {
          		target = <&hdmi1>;
          		__dormant__  {
          			dmas;
          		};
          	};

          	fragment@19 {
          		target-path = "/chosen";
          		__overlay__  {
          			bootargs = "snd_bcm2835.enable_hdmi=0";
          		};
          	};

          	fragment@20 {
          		target = <&dvp>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	fragment@21 {
          		target = <&pixelvalve3>;
          		__dormant__  {
          			status = "okay";
          		};
          	};

          	fragment@22 {
          		target = <&vec>;
          		__dormant__  {
          			status = "okay";
          		};
          	};

          	fragment@23 {
          		target = <&aon_intr>;
          		__overlay__  {
          			status = "okay";
          		};
          	};

          	__overrides__ {
          		audio   = <0>,"!17";
          		audio1   = <0>,"!18";
          		noaudio = <0>,"=17", <0>,"=18";
          		composite = <0>, "!1",
          			    <0>, "!2",
          			    <0>, "!3",
          			    <0>, "!4",
          			    <0>, "!6",
          			    <0>, "!7",
          			    <0>, "!8",
          			    <0>, "!9",
          			    <0>, "!10",
          			    <0>, "!16",
          			    <0>, "=21",
          			    <0>, "=22";
          		nohdmi0 =   <0>, "-1-3-8";
          		nohdmi1 =   <0>, "-2-4-10";
          		nohdmi =    <0>, "-1-2-3-4-8-10";
          	};
          };
        '';
      }
    ];
  };
}
