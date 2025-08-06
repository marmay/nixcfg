{ config, lib, self, pkgs, ... }:
{
  options.marmar.printingSupport = lib.mkEnableOption "Printing Support";

  config = lib.mkIf config.marmar.printingSupport {
    hardware.printers = {
      ensurePrinters = [
        {
    	  name = "BR_HL_L3210CW";
    	  location = "Keller@Zuhause";
    	  deviceUri = "ipp://BRW4CD577B1CE33.local:631/ipp/print";
	  model = "everywhere";
    	}
      ];
    };
	  
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      printing = {
        enable = true;
        browsing = true;
	browsed.enable = true;
	openFirewall = true;
        defaultShared = false;
	drivers = with pkgs; [ gutenprint brlaser ];
      };
    };
  };
}
