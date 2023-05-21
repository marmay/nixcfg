{ config, lib, pkgs, ... }:
{
  options.marmar.vc4-kms = lib.mkEnableOption "Enable vc4-kms";
  config = lib.mkIf config.marmar.vc4-kms {
    boot.kernelParams = [
      "video=HDMI-A-1:1920x1080M@60D"
      "vc4.force_hotplug=1"
      #"vc_mem.mem_base=0x3a303d00"
      #"vc_mem.mem_size=0x1fc00000"
      "snd_bcm2835.enable_hdmi=0"
      "snd_bcm2835.enable_headphones=0"
    ];
    hardware.deviceTree.filter = lib.mkForce "bcm2711-rpi-400.dtb";
    hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    hardware.deviceTree.overlays = [
      {
        name = "rpi4-vc4-kms-v3d-overlay";
        dtsText = ''
          /dts-v1/;
          
          / {
          	compatible = "brcm,bcm2711";
          
          	fragment@0 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			size = <0x1fc00000>;
          			phandle = <0x01>;
          		};
          	};
          
          	__overrides__ {
          		cma-512 = <0x01 0x73697a65 0x3a303d00 0x20000000>;
          		cma-448 = <0x01 0x73697a65 0x3a303d00 0x1c000000>;
          		cma-384 = <0x01 0x73697a65 0x3a303d00 0x18000000>;
          		cma-320 = <0x01 0x73697a65 0x3a303d00 0x14000000>;
          		cma-256 = <0x01 0x73697a65 0x3a303d00 0x10000000>;
          		cma-192 = <0x01 0x73697a65 0x3a303d00 0xc000000>;
          		cma-128 = <0x01 0x73697a65 0x3a303d00 0x8000000>;
          		cma-96 = <0x01 0x73697a65 0x3a303d00 0x6000000>;
          		cma-64 = <0x01 0x73697a65 0x3a303d00 0x4000000>;
          		cma-size = [00 00 00 01 73 69 7a 65 3a 30 00];
          		cma-default = [00 00 00 00 2d 30 00];
          		audio = <0x00 0x21313700>;
          		audio1 = <0x00 0x21313800>;
          		noaudio = <0x00 0x3d313700 0x00 0x3d313800>;
          		composite = <0x00 0x21310000 0x21 0x32000000 0x2133 0x00 0x213400 0x00 0x21360000 0x21 0x37000000 0x2138 0x00 0x213900 0x00 0x21313000 0x00 0x21313600 0x00 0x3d323100 0x00 0x3d323200>;
          		nohdmi0 = "\0\0\0\0-1-3-8";
          		nohdmi1 = "\0\0\0\0-2-4-10";
          		nohdmi = "\0\0\0\0-1-2-3-4-8-10";
          	};
          
          	fragment@1 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@2 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@3 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@4 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@5 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@6 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@7 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@8 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@9 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@10 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@11 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@12 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@13 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@14 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "disabled";
          		};
          	};
          
          	fragment@15 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "disabled";
          		};
          	};
          
          	fragment@16 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "disabled";
          		};
          	};
          
          	fragment@17 {
          		target = <0xffffffff>;
          
          		__dormant__ {
          			dmas;
          		};
          	};
          
          	fragment@18 {
          		target = <0xffffffff>;
          
          		__dormant__ {
          			dmas;
          		};
          	};
          
          	fragment@19 {
          		target-path = "/chosen";
          
          		__overlay__ {
          			bootargs = "snd_bcm2835.enable_hdmi=0";
          		};
          	};
          
          	fragment@20 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	fragment@21 {
          		target = <0xffffffff>;
          
          		__dormant__ {
          			status = "okay";
          		};
          	};
          
          	fragment@22 {
          		target = <0xffffffff>;
          
          		__dormant__ {
          			status = "okay";
          		};
          	};
          
          	fragment@23 {
          		target = <0xffffffff>;
          
          		__overlay__ {
          			status = "okay";
          		};
          	};
          
          	__symbols__ {
          		frag0 = "/fragment@0/__overlay__";
          	};
          
          	__fixups__ {
          		cma = "/fragment@0:target:0";
          		ddc0 = "/fragment@1:target:0";
          		ddc1 = "/fragment@2:target:0";
          		hdmi0 = "/fragment@3:target:0\0/fragment@17:target:0";
          		hdmi1 = "/fragment@4:target:0\0/fragment@18:target:0";
          		hvs = "/fragment@5:target:0";
          		pixelvalve0 = "/fragment@6:target:0";
          		pixelvalve1 = "/fragment@7:target:0";
          		pixelvalve2 = "/fragment@8:target:0";
          		pixelvalve3 = "/fragment@9:target:0\0/fragment@21:target:0";
          		pixelvalve4 = "/fragment@10:target:0";
          		v3d = "/fragment@11:target:0";
          		vc4 = "/fragment@12:target:0";
          		txp = "/fragment@13:target:0";
          		fb = "/fragment@14:target:0";
          		firmwarekms = "/fragment@15:target:0";
          		vec = "/fragment@16:target:0\0/fragment@22:target:0";
          		dvp = "/fragment@20:target:0";
          		aon_intr = "/fragment@23:target:0";
          	};
          
          	__local_fixups__ {
          
          		__overrides__ {
          			cma-512 = <0x00>;
          			cma-448 = <0x00>;
          			cma-384 = <0x00>;
          			cma-320 = <0x00>;
          			cma-256 = <0x00>;
          			cma-192 = <0x00>;
          			cma-128 = <0x00>;
          			cma-96 = <0x00>;
          			cma-64 = <0x00>;
          			cma-size = <0x00>;
          		};
          	};
          };
        '';
      }
    ];
    services.xserver.videoDrivers = lib.mkBefore [
      "modesetting" # Prefer the modesetting driver in X11
      "fbdev" # Fallback to fbdev
    ];
    services.xserver.displayManager.gdm.wayland = false;
  };
}
