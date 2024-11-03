{ config, lib, self, pkgs, ... }:
{
  options.marmar.printingSupport = lib.mkEnableOption "Printing Support";

  config = lib.mkIf config.marmar.printingSupport {
    hardware.printers = {
      ensurePrinters = [
        {
	  name = "Brother-HL3210CW";
	  location = "Keller";
	  deviceUri = "ipp://10.0.0.230:631/ipp/print";
	  model = "brother-BrGenML1-cups-en.ppd";
	  ppdOptions = {
	    PageSize = "A4";
	  };
	}
      ];
    };
    
    services = {
      avahi = {
        enable = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      printing = {
        enable = true;
	stateless = true;
        browsing = true;
        browsedConf = ''
	  BrowseOrder Allow,Deny
        '';
        listenAddresses = [ "*:631" ];
        allowFrom = [ "all" ];
        defaultShared = false;
        drivers = with pkgs; [
          brgenml1cupswrapper
        ];
      };
    };
  };
}
